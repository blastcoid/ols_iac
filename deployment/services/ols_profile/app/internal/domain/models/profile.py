# app/internal/domain/models/profile.py

import strawberry
from datetime import date, datetime
from pydantic import BaseModel, Field
from beanie import PydanticObjectId

# http
## Image
class Image(BaseModel):
    name: str | None = None
    url: str | None = None

class Address(BaseModel):
    types: str | None = None
    address: str | None = None
    subdistrict: str | None = None
    district: str | None = None
    city: str | None = None
    province: str | None = None
    country: str | None = None
    postalCode: int | None = None

## Profile
class Profile(BaseModel):
    id: PydanticObjectId = Field(alias="_id")
    userId: str
    firstname: str | None = None
    lastname: str | None = None
    birthdate: date | None = None
    gender: str | None = None
    addresses: list[Address] | None = None
    image: Image | None = None
    createdAt: datetime | None = None
    updatedAt: datetime | None = None

## ProfileCreate
class ProfileCreate(BaseModel):
    userId: str
    firstname: str | None = None
    lastname: str | None = None
    birthdate: date | None = None
    gender: str | None = None
    addresses: list[Address] | None = None
    image: Image | None = None
    createdAt: datetime | None = None
    updatedAt: datetime | None = None

## ProfileUpdate
class ProfileUpdate(BaseModel):
    userId: str | None = None
    firstname: str | None = None
    lastname: str | None = None
    birthdate: date | None = None
    gender: str | None = None
    addresses: list[Address] | None = None
    image: Image | None = None
    createdAt: datetime | None = None
    updatedAt: datetime | None = None

# graphql
@strawberry.type
class ImageGql:
    name: str | None = None
    url: str | None = None

@strawberry.type
class AddressGql:
    types: str | None = None
    address: str | None = None
    subdistrict: str | None = None
    district: str | None = None
    city: str | None = None
    province: str | None = None
    country: str | None = None
    postalCode: int | None = None

@strawberry.type
class ProfileGql:
    id: strawberry.ID
    userId: str
    firstname: str | None = None
    lastname: str | None = None
    birthdate: str | None = None
    gender: str | None = None
    addresses: list[AddressGql] | None = None
    image: ImageGql | None = None
    createdAt: str | None = None
    updatedAt: str | None = None

@strawberry.input
class ImageInputGql:
    name: str | None = None
    url: str | None = None

@strawberry.input
class AddressInputGql:
    types: str | None = None
    address: str | None = None
    subdistrict: str | None = None
    district: str | None = None
    city: str | None = None
    province: str | None = None
    country: str | None = None
    postalCode: int | None = None

@strawberry.input
class ProfileCreateInputGql:
    userId: str
    firstname: str | None = None
    lastname: str | None = None
    birthdate: str | None = None
    gender: str | None = None
    addresses: list[AddressInputGql] | None = None
    image: ImageInputGql | None = None
    createdAt: str | None = None
    updatedAt: str | None = None

@strawberry.input
class ProfileUpdateInputGql:
    userId: str | None = None
    firstname: str | None = None
    lastname: str | None = None
    birthdate: str | None = None
    gender: str | None = None
    addresses: list[AddressInputGql] | None = None
    image: ImageInputGql | None = None
    createdAt: str | None = None
    updatedAt: str | None = None