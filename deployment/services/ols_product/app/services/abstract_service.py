# app/services/abstract_service.py

from abc import ABC, abstractmethod
from fastapi import APIRouter, HTTPException, Request
from pydantic import BaseModel

class AbstractBaseService(ABC):
    @abstractmethod
    async def list(self, skip: int = 0, limit: int = 10) -> APIRouter:
        raise HTTPException(status_code=501, detail="Not Implemented")

    @abstractmethod
    async def get(self, request: Request, _id: str) -> APIRouter:
        raise HTTPException(status_code=501, detail="Not Implemented")

    @abstractmethod
    async def post(self, entity: BaseModel) -> APIRouter:
        raise HTTPException(status_code=501, detail="Not Implemented")

    @abstractmethod
    async def put(self, _id: str, entity: BaseModel) -> APIRouter:
        raise HTTPException(status_code=501, detail="Not Implemented")

    @abstractmethod
    async def delete(self, _id: str) -> APIRouter:
        raise HTTPException(status_code=501, detail="Not Implemented")