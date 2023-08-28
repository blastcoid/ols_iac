# app/api/v1/endpoints/product.py

from fastapi import APIRouter, status, Depends
from ....services.product_service import ProductService
from ....api.v1.dependencies import get_token_header
from ....db.models.product import Product, ProductCreate, ProductUpdate

product_service = ProductService()
product_router = APIRouter()

product_router.add_api_route("/products", product_service.list, methods=["GET"], response_model=list[Product])
product_router.add_api_route("/products/{product_id}", product_service.get, methods=["GET"], response_model=Product)
product_router.add_api_route("/products", product_service.post, methods=["POST"], response_model=ProductCreate, status_code=status.HTTP_201_CREATED, dependencies=[Depends(get_token_header)])
product_router.add_api_route("/products/{product_id}", product_service.put, methods=["PUT"], response_model=ProductUpdate, dependencies=[Depends(get_token_header)])
product_router.add_api_route("/products/{product_id}", product_service.delete, methods=["DELETE"], status_code=status.HTTP_204_NO_CONTENT)
