# app/internal/domain/interfaces/profile_interface.py

from abc import ABC, abstractmethod
from fastapi import HTTPException
from ..models.profile import Profile, ProfileCreate, ProfileUpdate

class ProfileInterface(ABC):
    @abstractmethod
    async def list(self, skip: int = 0, limit: int = 10) -> list:
        raise HTTPException(status_code=501, detail="Not Implemented")

    @abstractmethod
    async def get(self, _id: str) -> Profile:
        raise HTTPException(status_code=501, detail="Not Implemented")

    @abstractmethod
    async def create(self, entity: ProfileCreate) -> Profile:
        raise HTTPException(status_code=501, detail="Not Implemented")

    @abstractmethod
    async def update(self, _id: str, entity: ProfileUpdate) -> Profile:
        raise HTTPException(status_code=501, detail="Not Implemented")

    @abstractmethod
    async def delete(self, _id: str):
        raise HTTPException(status_code=501, detail="Not Implemented")