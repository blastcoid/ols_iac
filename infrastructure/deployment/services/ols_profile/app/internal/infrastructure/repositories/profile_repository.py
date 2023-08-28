# app/internal/infrastructure/repositories/profile_repository.py
from datetime import timedelta
from fastapi import HTTPException, status
from graphql import GraphQLError
from ...domain.interfaces.profile_interface import ProfileInterface
from ...domain.models.profile import Profile, ProfileCreate, ProfileUpdate, ProfileGql, ProfileCreateInputGql, ProfileUpdateInputGql
from ...infrastructure.setup import Mongo, Redis, log

class ProfileRepository(ProfileInterface):
    # Profile Repository constructor
    def __init__(self, transport: str = "http"):
        ## Transport
        self.transport = transport
        ## Initialize mongo and redis
        mongo = Mongo()
        redis = Redis()
        ## Access mongo client
        db = mongo.getDb()
        ## Get profile collection
        self.collection = db["Profile"]
        ## Access redis client
        self.redis_client = redis.getClient()
        ## Redis ttl
        self.redis_ttl = redis.getTtl()

    # MongoDb
    ## Check the existence of data
    async def isExist(self, id: str) -> bool:
        try:
            ### Get datum from mongodb
            datum = await self.collection.find_one({"userId": id})
            ### Check if datum exists in mongodb
            if datum:
                return True
            else:
                return False
        except Exception as e:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail = {
                    "msg": "Cannot check if profile datum exists",
                    "reason": str(e)
                }
            )

    ### check datum integrity
    async def isConflict(self, datum: ProfileCreate ) -> bool:
        try:
            ### Check if datum id already exist in mongodb
            datum = await self.collection.find_one({"userId": datum.userId})
            if datum:
                return True
            else:
                return False
        except Exception as e:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail = {
                    "msg": "Cannot check profile datum integrity",
                    "reason": str(e)
                }
            )

    ## List data with pagination
    async def list(self, skip: int = 0, limit: int = 10) -> list[Profile]:
        ## List Data
        try:
            data = await self.collection.find().skip(skip).limit(limit).to_list(length=limit)
        except Exception as e:
            if self.transport == "http":
                raise HTTPException(
                    status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                    detail = {
                        "msg": "Cannot list profile data",
                        "reason": str(e)
                    }
                )
            elif self.transport == "graphql":
                raise GraphQLError(
                    message = "Cannot list profile data",
                    extensions = {
                        "reason": str(e)
                    }
                )
        # for datum in data:
            ### convert _id to string
            # datum["_id"] = str(datum["_id"])
        return data

    ## Get datum by id
    async def get(self, id: str) -> Profile:
        try:
            ### Retrieve a datum
            datum = await self.collection.find_one({"userId": id})
        except Exception as e:
            ### Raise exception the transport is http
            if self.transport == "http":
                raise HTTPException(
                    status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                    detail = {
                        "msg": "Cannot get profile datum",
                        "reason": str(e)
                    }
                )
            ### Raise exception the transport is graphql
            elif self.transport == "graphql":
                raise GraphQLError(
                    message = "Cannot get profile datum",
                    extensions = {
                        "reason": str(e)
                    }
                )
        return datum
    
    ## Create datum
    async def create(self, datum: ProfileCreate)-> ProfileCreate:
        try:
            ## create datum in mongodb
            temp = await self.collection.insert_one(datum)
            return datum
        except Exception as e:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail = {
                    "msg": "Cannot create profile datum",
                    "reason": str(e)
                }
            )
        
    ## Update a datum
    async def update(self, id: str, datum: ProfileUpdate):
        try:
            # update_operations = {}

            # # If address is in datum, set each field of each address separately
            # if 'address' in datum:
            #     for idx, address in enumerate(datum['address']):
            #         for field in address:
            #             if address[field] is not None:
            #                 update_operations[f"address.{idx}.{field}"] = address[field]
            #     datum.pop('address')

            # # If image is in datum, set each field of image separately
            # if 'image' in datum:
            #     for field in datum['image']:
            #         if datum['image'][field] is not None:
            #             update_operations[f"image.{field}"] = datum['image'][field]
            #     datum.pop('image')

            # if update_operations:
            #     await self.collection.update_one({"userId": id}, {"$set": update_operations})

            # Update the rest of the fields
            await self.collection.update_one({"userId": id}, {"$set": datum})
        except Exception as e:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail = {
                    "msg": "Cannot update profile datum",
                    "reason": str(e)
                }
            )
        
    ## Delete a datum
    async def delete(self, id: str):
        try:
            ### delete datum from mongodb
            await self.collection.delete_one({"userId": id})
        except Exception as e:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail = {
                    "msg": "Cannot delete profile datum",
                    "reason": str(e)
                }
            )
        
    # Redis
    ### get datum from redis
    async def getCache(self, id: str) -> str:
        try:
            ### get datum from redis
            value = await self.redis_client.get(f"profile:{id}")
            if value:
                log.debug(f"Profile datum is retrieved from Redis")
            else:
                log.debug(f"Profile datum is not retrieved from Redis")
            return value
        except Exception as e:
            if self.transport == "http":
                raise HTTPException(
                    status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                    detail = {
                        "msg": "Cannot get profile datum from Redis",
                        "reason": str(e)
                    }
                )
            elif self.transport == "graphql":
                raise GraphQLError(
                    message="Cannot get profile datum from Redis",
                    extensions={
                        "reason": str(e)
                    }
                )

    ## set datum to redis with ttl
    async def setCache(self, id: str, profile: Profile):
        try:
            ### set profile data to redis with ttl
            is_cache = await self.redis_client.setex(f"profile:{id}", timedelta(seconds=self.redis_ttl), profile)
            if is_cache:
                log.debug(f"Profile datum is set to Redis with ttl {self.redis_ttl} seconds")
            else:
                log.debug(f"Profile datum is not set to Redis")
        except Exception as e:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail = {
                    "error": "Cannot set profile datum to Redis",
                    "reason": str(e)
                }
            )
        
    ## delete datum from redis
    async def deleteCache(self, id: str):
        try:
            ### delete datum from redis and get number of deleted keys
            num = await self.redis_client.delete(f"profile:{id}")
            if num >= 1:
                log.debug(f"Profile datum is deleted from Redis")
            else:
                log.debug(f"Profile datum is not deleted from Redis")
        except Exception as e:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail = {
                    "error": "Cannot delete profile datum from Redis",
                    "reason": str(e)
                }
            )
        
    ## get redis ttl
    async def getTtl(self, id: str) -> int:
        try:
            ### get redis ttl
            ttl = await self.redis_client.ttl(f"profile:{id}")
            return ttl
        except Exception as e:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail = {
                    "error": "Cannot get ttl from Redis",
                    "reason": str(e)
                }
            )