# app/services/product_service.py
from datetime import datetime
from fastapi import status, APIRouter, HTTPException, Request, Response
from fastapi.responses import JSONResponse
from starlette.exceptions import HTTPException
from ..db.repositories.product_repository import ProductRepository
from ..db.models.product import ProductCreate, ProductUpdate
from ..services.abstract_service import AbstractBaseService
from ..core.databases import redis
from ..core.logger import log

## Product Service
class ProductService(AbstractBaseService):
    def __init__(self):
        self.product_repo = ProductRepository()

    async def list(self, skip: int = 0, limit: int = 10) -> APIRouter:
        products = await self.product_repo.get_all(skip, limit)
        return products

    async def get(self, request: Request, product_id: str) -> APIRouter:
        ### check if request header has if-none-match & and return 304 not modified
        if request.headers.get("if-none-match") == "W/"+product_id:
            ttl = await redis.ttl(f"product:{product_id}")
            return Response(status_code=304, headers={"Cache-Control": f"max-age={ttl}"})
        ### get product from repository
        log.debug("product_id: %s", product_id)
        product = await self.product_repo.get_one(product_id)
        ### check if product exists
        if not product["result"]:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Product not found")
        ### create response
        response = JSONResponse(content=dict(product["data"]))
        ### check if product is cached
        if product["cached"]:
            ### add headers
            response.headers["X-Cache"] = "HIT"
            response.headers["Cache-Control"] = "max-age=3600"
            response.headers["Expires"] = "3600"
            response.headers["Etag"] = "W/"+product["data"]["_id"]
        else:
            response.headers["X-Cache"] = "MISS"
        return response
    
    async def post(self, product: ProductCreate) -> APIRouter:
        ### check data integrity
        if await self.product_repo.is_conflict(product):
            raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="Product SKU or name already exist")
        product.created_at = datetime.now().isoformat()
        product = await self.product_repo.create(product.dict())
        return product

    async def put(self, product_id: str, product: ProductUpdate) -> APIRouter:
        ### check if product exists
        if not await self.product_repo.is_exist(product_id):
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Product not found")
        product.updated_at = datetime.now().isoformat()
        ### update product
        product = await self.product_repo.update(product_id, product.dict(exclude_unset=True))
        return product

    async def delete(self, product_id: str):
        ### check if product exists
        if not await self.product_repo.is_exist(product_id):
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Product not found")
        ### delete product
        await self.product_repo.delete(product_id)
