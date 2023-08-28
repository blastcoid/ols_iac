# app/dependencies.py

from functools import lru_cache
from fastapi import Header, HTTPException, status
from graphql import GraphQLError
from .internal.config import Settings

@lru_cache()
def get_settings():
    return Settings()

# Token header dependency
async def get_token_header(authorization: str = Header(None), transport: str = "http"):
    #Get the authorization bearer token
    if authorization is None:
        if transport == "graphql":
            raise GraphQLError(f'Unauthorized: Missing authorization header')
        else:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail= {
                    "error": "Unauthorized",
                    "reason": "Missing authorization header"
                }
            )
    token_type, token = authorization.split(" ")
    if token_type != "Bearer":
        if transport == "graphql":
            raise GraphQLError(f'Unauthorized: Invalid token type')
        else:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail= {
                    "error": "Unauthorized",
                    "reason": "Invalid token type"
                }
            )
    # Verify the token by hitting the redis cache
    from .internal.infrastructure.setup import Redis
    try:
        redis_client = Redis().getClient()
        is_token = await redis_client.get(f"fastapi_users_token:{token}")
    except Exception as e:
        if transport == "graphql":
            raise GraphQLError(
                message="Cannot get token from Redis",
                extensions={
                    "reason": str(e)
                }
            )
        else:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail = {
                    "error": "Cannot get token from Redis",
                    "reason": str(e)
                }
            )
    if not is_token:
        if transport == "graphql":
            raise GraphQLError(f'Unauthorized: Invalid token')
        else:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail= {
                    "error": "Unauthorized",
                    "reason": "Invalid token"
                }
            )
    return {"token": token}

# # Profile repository dependency
# def get_profile_repo() -> ProfileRepository:
#     return ProfileRepository("graphql")