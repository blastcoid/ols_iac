# app/services/profile_service.py
import ujson, json
from datetime import datetime
from fastapi import status, APIRouter, HTTPException, Request, Response
from fastapi.responses import JSONResponse
from starlette.exceptions import HTTPException
from ...domain.models.profile import ProfileCreate, ProfileUpdate
from ...infrastructure.repositories.profile_repository import ProfileRepository
from ...infrastructure.setup import log

class ProfileService:
    def __init__(self):
        self.profile_repo = ProfileRepository()

    async def list(self, skip: int = 0, limit: int = 10) -> APIRouter:
        profiles = await self.profile_repo.list(skip, limit)
        return profiles

    # Get a profile data for http
    async def get(self, profileUserId: str, request: Request=None) -> APIRouter:
        ttl = await self.profile_repo.getTtl(profileUserId)
        ## check if request header has if-none-match & and return 304 not modified
        if request:
            if request.headers.get("if-none-match") == "W/"+profileUserId and ttl > 0:
                return Response(status_code=304, headers={"Cache-Control": f"max-age={ttl}"})
            ## check if profile is cached
        profile = await self.profile_repo.getCache(profileUserId)
        if profile:
            ## create response
            response = JSONResponse(content=ujson.loads(profile))
            ## add cache hit headers
            response.headers["X-Cache"] = "HIT"
            ttl = await self.profile_repo.getTtl(profileUserId)
            response.headers["Cache-Control"] = f"max-age={ttl}"
            response.headers["Expires"] = str(ttl)
            response.headers["Etag"] = "W/"+profileUserId
            return response
        ## if profile is not cached, get profile db
        profile = await self.profile_repo.get(profileUserId)
        ## check if profile exists
        if not profile:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Profile not found")
        ## convert profile id to string
        profile["_id"] = str(profile["_id"])
        ## cache profile
        await self.profile_repo.setCache(profileUserId, ujson.dumps(profile))
        ## create response
        response = JSONResponse(content=profile)
        ## add cache miss headers
        response.headers["X-Cache"] = "MISS"
        return response
    
    # Create a profile data
    async def post(self, profile: ProfileCreate) -> APIRouter:
        ## check data integrity
        if await self.profile_repo.isConflict(profile):
            raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="Profile user id already exist")
        if profile.birthdate:
            profile.birthdate = profile.birthdate.isoformat()
        profile.updatedAt = datetime.now().isoformat()
        profile.createdAt = datetime.now().isoformat()
        profile = await self.profile_repo.create(profile.dict())
        return profile

    # Update a profile data
    async def put(self, profileUserId: str, profile: ProfileUpdate) -> APIRouter:
        ## check if profile exists
        if not await self.profile_repo.isExist(profileUserId):
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Profile not found")
        ## convert birthdate to isoformat
        if profile.birthdate:
            profile.birthdate = profile.birthdate.isoformat()
        profile.updatedAt = datetime.now().isoformat()
        ## update profile
        await self.profile_repo.update(profileUserId, profile.dict(exclude_unset=True))
        ## delete profile cache
        await self.profile_repo.deleteCache(profileUserId)
        ## get updated profile
        profile = await self.profile_repo.get(profileUserId)
        return profile

    # Delete a profile data
    async def delete(self, profileUserId: str):
        ## check if profile exists
        if not await self.profile_repo.isExist(profileUserId):
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Profile not found")
        ## delete profile
        await self.profile_repo.delete(profileUserId)
        ## delete profile cache
        await self.profile_repo.deleteCache(profileUserId)
