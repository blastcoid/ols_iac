# app/db/repositories/product_repository.py

import json
from bson import ObjectId
from datetime import timedelta
from fastapi import HTTPException, status
from ...core.logger import log
from ...core.databases import db, redis
from ...db.models.product import Product, ProductCreate, ProductUpdate
from ...db.repositories.abstract_repository import AbstractBaseRepository

class ProductRepository(AbstractBaseRepository):
    ### Product Repository constructor
    def __init__(self):
        try:
            self.collection = db["Product"]
        except Exception as e:
            raise HTTPException(status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Internal Server Error")

    ### Check if product exists
    async def is_exist(self, product_id: str) -> bool:
        try:
            ### Check if product exists in mongodb
            log.debug("product_id: %s", product_id)
            product = await self.collection.find_one({"_id": ObjectId(product_id)})
            if product:
                return True
            else:
                return False
        except Exception as e:
            raise HTTPException(status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Internal Server Error")
        
    ### check data integrity
    async def is_conflict(self, product: ProductCreate ) -> bool:
        try:
            ### Check if product sku or product name exists in mongodb
            product = await self.collection.find_one({"$or": [{"sku": product.sku}, {"name": product.name}]})
            if product:
                return True
            else:
                return False
            
        except Exception as e:
            raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Internal Server Error")
        
    ### check redis ttl
    async def check_ttl(self, product_id: str) -> bool:
        try:
            ### Check if product exists in redis
            ttl = await redis.ttl(f"product:{product_id}")
            if ttl > 0:
                return True
            else:
                return False
        except Exception as e:
            raise HTTPException(status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Internal Server Error")

    ### List all products
    async def get_all(self, skip: int = 0, limit: int = 10) -> list[Product]:
        ### get all products
        try:
            data = await self.collection.find().skip(skip).limit(limit).to_list(length=limit)
            for datum in data:
                ### convert _id to string
                datum["_id"] = str(datum["_id"])
            return data
        except Exception as e:
            raise HTTPException(status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Internal Server Error")

    ### Get one product
    async def get_one(self, product_id: str) -> Product:
        log.debug("Enter get_one")
        product = {"result": False, "cached": False, "data": None}
        try:
            ### Check if product is cached
            datum = await redis.get(f"product:{product_id}")
            log.debug("Enter get_one")
            if datum:
                log.debug("Data Product retrieved from cache")
                ### convert data to dict
                datum = json.loads(datum)
                ### add data to product
                product["data"] = datum
                ### mark product as Hit and found
                product["cached"] = True
                product["result"] = True
                return product
            ### Retrieve a product
            datum = await self.collection.find_one({"_id": ObjectId(product_id)})
            print("datum: ", datum)
            ### check if product exists
            if not datum:
                return product
            ### convert data id to string
            datum["_id"] = str(datum["_id"])
            ### cache product data and set expiration to 1 hour
            await redis.setex(f"product:{product_id}", timedelta(hours=1), json.dumps(datum))
            log.debug("Cache data product")
            ### add data to product
            product["data"] = datum
            ### mark product as found
            product["result"] = True
            return product
        except Exception as e:
            raise HTTPException(status.HTTP_500_INTERNAL_SERVER_ERROR, detail=str(e))
        
    ### Create a product
    async def create(self, product: ProductCreate)-> ProductCreate:
        try:
            ### create product in mongodb
            datum = await self.collection.insert_one(product)
            ### add id to product
            id = str(datum.inserted_id)
            product["_id"] = id
            return product
        except Exception as e:
            raise HTTPException(status.HTTP_500_INTERNAL_SERVER_ERROR, detail=str(e))
        
    ### Update a product
    async def update(self, product_id: str, product: ProductUpdate) -> ProductUpdate:
        try:
            ### update product in mongodb
            await self.collection.update_one({"_id": ObjectId(product_id)}, {"$set": product})
            ### delete cache
            await redis.delete(f"product:{product_id}")
            ### add id to product
            product["_id"] = product_id
            return product
        except Exception as e:
            raise HTTPException(status.HTTP_500_INTERNAL_SERVER_ERROR, detail=str(e))
        
    ### Delete a product
    async def delete(self, product_id: str):
        try:
            ### delete product from mongodb
            await self.collection.delete_one({"_id": ObjectId(product_id)})
            ### delete cache
            await redis.delete(f"product:{product_id}")
        except Exception as e:
            raise HTTPException(status.HTTP_500_INTERNAL_SERVER_ERROR, detail=str(e))
