# app/api/v1/endpoints/category.py

from fastapi import APIRouter, status, Depends
from ....services.category_service import CategoryService
from ....api.v1.dependencies import get_token_header
from ....db.models.category import Category

category_service = CategoryService()
category_router = APIRouter()

category_router.add_api_route("/categories", category_service.list, methods=["GET"], response_model=list[Category])
category_router.add_api_route("/categories/{category_id}", category_service.get, methods=["GET"], response_model=Category)
category_router.add_api_route("/categories", category_service.post, methods=["POST"], response_model=Category, status_code=status.HTTP_201_CREATED, dependencies=[Depends(get_token_header)])
category_router.add_api_route("/categories/{category_id}", category_service.put, methods=["PUT"], response_model=Category, dependencies=[Depends(get_token_header)])
category_router.add_api_route("/categories/{category_id}", category_service.delete, methods=["DELETE"], status_code=status.HTTP_204_NO_CONTENT)
