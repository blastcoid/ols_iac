# app/db/models/category.py

from pydantic import BaseModel, Field

### Category
class Category(BaseModel):
    id: str = Field(..., alias="_id")
    name: str
    description: str | None = None
    created_at: str | None = None
    updated_at: str | None = None

### CategoryCreate
class CategoryCreate(BaseModel):
    name: str
    description: str | None = None
    parent_id: str | None = None
    created_at: str | None = None
    updated_at: str | None = None

### CategoryUpdate
class CategoryUpdate(BaseModel):
    name: str | None = None
    description: str | None = None
    parent_id: str | None = None
    created_at: str | None = None
    updated_at: str | None = None