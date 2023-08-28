# app/db/repositories/abstract_repository.py

from abc import ABC, abstractmethod
from fastapi import HTTPException
from pydantic import BaseModel

class AbstractBaseRepository(ABC):
    @abstractmethod
    async def get_all(self, skip: int = 0, limit: int = 10) -> list:
        raise HTTPException(status_code=501, detail="Not Implemented")

    @abstractmethod
    async def get_one(self, _id: str) -> list:
        raise HTTPException(status_code=501, detail="Not Implemented")

    @abstractmethod
    async def create(self, entity: BaseModel) -> BaseModel:
        raise HTTPException(status_code=501, detail="Not Implemented")

    @abstractmethod
    async def update(self, _id: str, entity: BaseModel) -> BaseModel:
        raise HTTPException(status_code=501, detail="Not Implemented")

    @abstractmethod
    async def delete(self, _id: str) -> BaseModel:
        raise HTTPException(status_code=501, detail="Not Implemented")