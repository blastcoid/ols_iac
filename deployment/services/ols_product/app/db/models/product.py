# app/db/models/product.py

from beanie import PydanticObjectId
from pydantic import BaseModel, Field

## Image
class Image(BaseModel):
    name: str
    url: str

### Product
class Product(BaseModel):
    id: PydanticObjectId = Field(alias="_id")
    sku: str
    name: str
    price: float | None = None
    quantity: int | None = None
    category_id: str
    weight:  float | None = None
    dimension: str | None = None
    description:  str | None = None
    image: list[Image] | None = None
    created_at: str | None = None
    updated_at: str | None = None

### ProductCreate
class ProductCreate(BaseModel):
    sku: str
    name: str
    price: float | None = None
    quantity: int | None = None
    category_id: str
    weight:  float | None = None
    dimension: str | None = None
    description:  str | None = None
    image: list[Image] | None = None
    created_at: str | None = None
    updated_at: str | None = None

### ProductUpdate
class ProductUpdate(BaseModel):
    sku: str | None = None
    name: str | None = None
    price: float | None = None
    quantity: int | None = None
    category_id: str | None = None
    weight:  float | None = None
    dimension: str | None = None
    description:  str | None = None
    image: list[Image] | None = None
    created_at: str | None = None
    updated_at: str | None = None