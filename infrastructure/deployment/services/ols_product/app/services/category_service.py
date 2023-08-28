# app/services/category_service.py

from fastapi import status, APIRouter, HTTPException, Request, Response
from datetime import datetime
from fastapi.responses import JSONResponse
from starlette.exceptions import HTTPException
from ..db.repositories.category_repository import CategoryRepository
from ..db.models.category import CategoryCreate, CategoryUpdate
from ..services.abstract_service import AbstractBaseService
from ..core.databases import redis

## Category Service
class CategoryService(AbstractBaseService):
    def __init__(self):
        self.category_repo = CategoryRepository()

    async def list(self, skip: int = 0, limit: int = 10) -> APIRouter:
        categories = await self.category_repo.get_all(skip, limit)
        return categories

    async def get(self, request: Request, category_id: str) -> APIRouter:
        ### check if request header has if-none-match & and return 304 not modified
        if request.headers.get("if-none-match") == "W/"+category_id:
            ttl = await redis.ttl(f"category:{category_id}")
            return Response(status_code=304, headers={"Cache-Control": f"max-age={ttl}"})
        ### get category from repository
        category = await self.category_repo.get_one(category_id)
        ### check if category exists
        if not category["result"]:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Category not found")
        ### create response
        response = JSONResponse(content=dict(category["data"]))
        ### check if category is cached
        if category["cached"]:
            ### add headers
            response.headers["X-Cache"] = "HIT"
            response.headers["Cache-Control"] = "max-age=3600"
            response.headers["Expires"] = "3600"
            response.headers["Etag"] = "W/"+category["data"]["_id"]
        else:
            response.headers["X-Cache"] = "MISS"
        return response
    
    async def post(self, category: CategoryCreate) -> APIRouter:
        ### check data integrity
        if await self.category_repo.is_conflict(category):
            raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="Category name already exist")
        category.created_at = datetime.now().isoformat()
        category = await self.category_repo.create(category.dict())
        return category

    async def put(self, category_id: str, category: CategoryUpdate) -> APIRouter:
        ### check if category exists
        if not await self.category_repo.is_exist(category_id):
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Category not found")
        category.updated_at = datetime.now().isoformat()
        ### update category
        category = await self.category_repo.update(category_id, category.dict(exclude_unset=True))
        return category

    async def delete(self, category_id: str):
        ### check if category exists
        if not await self.category_repo.is_exist(category_id):
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Category not found")
        ### delete category
        await self.category_repo.delete(category_id)