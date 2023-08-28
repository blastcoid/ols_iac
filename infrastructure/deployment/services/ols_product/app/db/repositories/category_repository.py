import json
from bson import ObjectId
from datetime import timedelta
from fastapi import HTTPException, status
from fastapi.middleware.cors import CORSMiddleware
from starlette.concurrency import iterate_in_threadpool
from ...core.logger import log
from ...core.databases import db, redis
from ...db.models.category import Category, CategoryCreate, CategoryUpdate
from ...db.repositories.abstract_repository import AbstractBaseRepository

class CategoryRepository(AbstractBaseRepository):
    ### Constructor
    def __init__(self):
        try:
            ### access mongodb category collection
            self.collection = db["Category"]
        except Exception as e:
            raise HTTPException(status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Internal Server Error")
        
    ###check if category exists
    async def is_exist(self, category_id: str) -> bool:
        try:
            ### Check if category exists
            category = await self.collection.find_one({"_id": ObjectId(category_id)})
            if category:
                return True
            else:
                return False
        except Exception as e:
            raise HTTPException(status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Internal Server Error")
        
     ### check data integrity
    async def is_conflict(self, category: str) -> bool:
        try:
            category = await self.collection.find_one({"name": category.name})
            if category:
                return True
            else:
                return False
        except Exception as e:
            raise HTTPException(status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Internal Server Error")

    ### List categories
    async def get_all(self, skip: int = 0, limit: int = 10) -> list[Category]:
        ### get all categories from mongodb with pagination
        try:
            data = await self.collection.find().skip(skip).limit(limit).to_list(length=limit)
            for datum in data:
                ### convert _id to string
                datum["_id"] = str(datum["_id"])
            return data
        except Exception as e:
            raise HTTPException(status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Internal Server Error")

    ### Get a category
    async def get_one(self, category_id: str) -> Category:
        ### throw http 500 exception if redis or mongodb is down
        category = {"result": False, "cached": False, "data": None}
        try:
            ### Check if category is cached
            datum = await redis.get(f"category:{category_id}")
            if datum:
                log.debug("Data Category retrieved from cache")
                ### convert data to json
                datum = json.loads(datum)
                ### add data to category
                category["data"] = datum
                ### mark category as Hit
                category["cached"] = True
                ### mark category as found
                category["result"] = True
                return category
            ### Retrieve a single category by _id from the collection
            datum = await self.collection.find_one({"_id": ObjectId(category_id)})
            ### check if category exists
            if not datum:
                return category
            ### convert data id to string
            datum["_id"] = str(datum["_id"])
            ### cache category data and set expiration to 1 hour
            await redis.setex(f"category:{category_id}", timedelta(hours=1), json.dumps(datum))
            log.debug("Cache data category")
            ### add data to category
            category["data"] = datum
            ### mark category as found
            category["result"] = True
            return category
        except Exception as e:
            raise HTTPException(status.HTTP_500_INTERNAL_SERVER_ERROR, detail=str(e))


    ### Create a category
    async def create(self, category: CategoryCreate)-> Category:
        try:
            ### create category in mongodb
            datum = await self.collection.insert_one(category)
            ### add id to category
            id = str(datum.inserted_id)
            category["_id"] = id
            return category
        except Exception as e:
            raise HTTPException(status.HTTP_500_INTERNAL_SERVER_ERROR, detail=str(e))

    ### Update a category
    async def update(self, category_id: str, category: CategoryUpdate) -> Category:
        try:
            ### update category in mongodb
            await self.collection.update_one({"_id": ObjectId(category_id)}, {"$set": category})
            ### delete cache
            await redis.delete(f"category:{category_id}")
            ### get updated category
            category = await self.collection.find_one({"_id": ObjectId(category_id)})
            ### convert _id to string
            category["_id"] = str(category["_id"])
            return category
        except Exception as e:
            raise HTTPException(status.HTTP_500_INTERNAL_SERVER_ERROR, detail=str(e))
    
    ### Delete a category
    async def delete(self, category_id: str):
        try:
            ### delete category from mongodb
            await self.collection.delete_one({"_id": ObjectId(category_id)})
            ### delete cache
            await redis.delete(f"category:{category_id}")
        except Exception as e:
            raise HTTPException(status.HTTP_500_INTERNAL_SERVER_ERROR, detail=str(e))