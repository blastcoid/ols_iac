# app/api/v1/dependencies.py

from fastapi import Header, HTTPException
from ...core.databases import redis

# Token header dependency
async def get_token_header(authorization: str = Header(...)):
    #Get the authorization bearer token
    if not authorization:
        raise HTTPException(status_code=401, detail="Authorization header not provided")
    token_type, token = authorization.split(" ")
    if token_type != "Bearer":
        raise HTTPException(status_code=401, detail="Authorization header invalid")
    # Verify the token by hitting the redis cache
    is_token = await redis.get(f"fastapi_users_token:{token}")
    if not is_token:
        raise HTTPException(status_code=401, detail="Action is unauthorized")
    return token