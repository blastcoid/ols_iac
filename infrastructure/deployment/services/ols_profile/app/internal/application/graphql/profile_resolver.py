# app/internal/application/graphql/profile_resolvers.py

import ujson, strawberry
from datetime import datetime
from functools import cached_property
from fastapi import Depends, Request
from strawberry.fastapi import BaseContext
from graphql import GraphQLError
from ...domain.models.profile import ImageGql, AddressGql, ProfileGql, ImageInputGql, AddressInputGql, ProfileCreateInputGql, ProfileUpdateInputGql
from ...infrastructure.repositories.profile_repository import ProfileRepository
# from ....dependencies import get_profile_repo
from ...infrastructure.setup import log
from ....dependencies import get_token_header
from strawberry.types import Info as _Info
from strawberry.types.info import RootValueType

profile_repo = ProfileRepository("graphql")

class Context(BaseContext):
    def __init__(self, request: Request):
        self.request = request

    @cached_property
    async def profile(self) -> ProfileGql | None:
        if not self.request:
            return None

        ## Get token from header
        authorization = self.request.headers.get("Authorization", None)
        ## Get token from redis
        return await get_token_header(authorization, "graphql")
    
Info = _Info[Context, RootValueType]

@strawberry.type
class ProfileQuery:

    ## List profiles with pagination
    @strawberry.field
    async def list(self, info: Info, skip: int = 0, limit: int = 10) -> list[ProfileGql]:
        ## Authorization
        context_profile = await info.context.profile
        if not context_profile:
            raise GraphQLError(f"Unauthorized")
        ## Get profiles from mongodb
        profiles = await profile_repo.list(skip, limit)
        result = []
        ## convert profiles dict to ProfileGql object
        for profile in profiles:
            addresses = [AddressGql(**address) for address in profile.get('addresses', [])] if profile.get('addresses', []) else None
            image = ImageGql(**profile['image']) if profile.get('image') else None
            result.append(ProfileGql(
                id=strawberry.ID(profile['_id']), 
                userId=profile['userId'], 
                firstname=profile.get('firstname'), 
                lastname=profile.get('lastname'), 
                birthdate=profile.get('birthdate'), 
                gender=profile.get('gender'), 
                addresses=addresses, 
                image=image, 
                createdAt=profile.get('createdAt'), 
                updatedAt=profile.get('updatedAt')
            ))
        return result
    
    ## Get profile by userId
    @strawberry.field
    async def get(self,info: Info, userId: str) -> ProfileGql:
        context_profile = await info.context.profile
        if not context_profile:
            raise GraphQLError(f"Unauthorized")
        ## Get profile from redis
        profile = await profile_repo.getCache(userId)
        if profile:
            profile = ujson.loads(profile)
        else:
            ## Get profile from mongodb
            profile = await profile_repo.get(userId)
            if profile is None:
                raise GraphQLError(f"Profile not found")
            ## convert profile id to string
            profile['_id'] = str(profile['_id'])
            ## Set profile to redis
            await profile_repo.setCache(userId, ujson.dumps(profile)) 
        ## convert profile dict to ProfileGql object
        addresses = [AddressGql(**address) for address in profile.get('addresses', [])] if profile and profile.get('addresses', []) else None
        image = ImageGql(**profile['image']) if profile and profile.get('image') else None
        return ProfileGql(
            id=strawberry.ID(profile['_id']), 
            userId=profile['userId'], 
            firstname=profile.get('firstname'), 
            lastname=profile.get('lastname'), 
            birthdate=profile.get('birthdate'), 
            gender=profile.get('gender'), 
            addresses=addresses, 
            image=image, 
            createdAt=profile.get('createdAt'), 
            updatedAt=profile.get('updatedAt')
        )
    
@strawberry.type
class ProfileMutation:

    @strawberry.mutation
    async def post(self, info: Info, profileInput: ProfileCreateInputGql) -> ProfileGql:
        # Authorization
        context_profile = await info.context.profile
        if not context_profile:
            raise GraphQLError("Unauthorized")
        # Convert input to a dict using vars()
        profile_data = vars(profileInput)
        profile_data["addresses"] = [vars(address) for address in profile_data["addresses"]]
        profile_data["image"] = vars(profile_data["image"])

        profile_data["updatedAt"] = datetime.now().isoformat()
        profile_data["createdAt"] = datetime.now().isoformat()
        # Create profile (this might need to be modified based on the actual repository methods)
        created_profile = await profile_repo.create(profile_data)
        
        # Convert the returned profile data to ProfileGql and return
        addresses = [AddressGql(**address) for address in created_profile.get('addresses', [])] if created_profile.get('addresses', []) else None
        image = ImageGql(**created_profile['image']) if created_profile.get('image') else None
        
        return ProfileGql(
            id=strawberry.ID(created_profile['_id']), 
            userId=created_profile['userId'], 
            firstname=created_profile.get('firstname'), 
            lastname=created_profile.get('lastname'), 
            birthdate=created_profile.get('birthdate'), 
            gender=created_profile.get('gender'), 
            addresses=addresses, 
            image=image, 
            createdAt=created_profile.get('createdAt'), 
            updatedAt=created_profile.get('updatedAt')
        )
    
    @strawberry.mutation
    async def put(self, info: Info, userId: str, profileInput: ProfileUpdateInputGql) -> ProfileGql:
        # Authorization
        context_profile = await info.context.profile
        if not context_profile:
            raise GraphQLError("Unauthorized")
        
        # Convert input to a dict using vars()
        profile_data = vars(profileInput)
        if profile_data.get("addresses"):
            profile_data["addresses"] = [vars(address) for address in profile_data["addresses"]]
        if profile_data.get("image"):
            profile_data["image"] = vars(profile_data["image"])
        profile_data["updatedAt"] = datetime.now().isoformat()
        # Update profile (this might need to be modified based on the actual repository methods)
        await profile_repo.update(userId, profile_data)
        updated_profile = await profile_repo.get(userId)
        # Convert the returned profile data to ProfileGql and return
        addresses = [AddressGql(**address) for address in updated_profile.get('addresses', [])] if updated_profile.get('addresses', []) else None
        image = ImageGql(**updated_profile['image']) if updated_profile.get('image') else None

        return ProfileGql(
            id=strawberry.ID(updated_profile['_id']), 
            userId=updated_profile['userId'], 
            firstname=updated_profile.get('firstname'), 
            lastname=updated_profile.get('lastname'), 
            birthdate=updated_profile.get('birthdate'), 
            gender=updated_profile.get('gender'), 
            addresses=addresses, 
            image=image, 
            createdAt=updated_profile.get('createdAt'), 
            updatedAt=updated_profile.get('updatedAt')
        )

    @strawberry.mutation
    async def delete(self, userId: str) -> None:
        await profile_repo.delete(str(userId))