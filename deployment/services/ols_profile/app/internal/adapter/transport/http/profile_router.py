# app/internal/adapter/transport/http/profile_http_router.py

from fastapi import APIRouter, status, Depends
from ....domain.models.profile import Profile
from ....application.http.profile_service import ProfileService
from .....dependencies import get_token_header

profile_service = ProfileService()
profile_http_router = APIRouter()

profile_http_router.add_api_route("/profiles", profile_service.list, methods=["GET"], response_model=list[Profile], dependencies=[Depends(get_token_header)])
profile_http_router.add_api_route("/profiles/{profileUserId}", profile_service.get, methods=["GET"], response_model=Profile, dependencies=[Depends(get_token_header)])
profile_http_router.add_api_route("/profiles", profile_service.post, methods=["POST"], response_model=Profile, status_code=status.HTTP_201_CREATED, dependencies=[Depends(get_token_header)])
profile_http_router.add_api_route("/profiles/{profileUserId}", profile_service.put, methods=["PUT"], response_model=Profile, dependencies=[Depends(get_token_header)])
profile_http_router.add_api_route("/profiles/{profileUserId}", profile_service.delete, methods=["DELETE"], status_code=status.HTTP_204_NO_CONTENT, dependencies=[Depends(get_token_header)])