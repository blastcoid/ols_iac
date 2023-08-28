import uvicorn, orjson, json, uuid, logging
from time import time
import motor.motor_asyncio
import redis.asyncio
from pydantic import BaseSettings
from typing import Optional
from beanie import init_beanie, Document, PydanticObjectId
from fastapi import Depends, FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.middleware.trustedhost import TrustedHostMiddleware
from fastapi.middleware.gzip import GZipMiddleware
from fastapi_users.db import BeanieBaseUser, BeanieUserDatabase
from fastapi_users import schemas, BaseUserManager, FastAPIUsers
from fastapi_users.authentication import (
    AuthenticationBackend,
    BearerTransport,
    # JWTStrategy,
    RedisStrategy
)
from fastapi_users.db import BeanieUserDatabase, ObjectIDIDMixin

# BaseSettings subclass for application settings
class Settings(BaseSettings):
    # App settings
    app_host: str = "0.0.0.0"
    app_port: int = 8000
    app_log_level: str = "warning"
    # MongoDB connection settings
    mongodb_host: str = "127.0.0.1"
    mongodb_port: int = 27017
    mongodb_db: str = "product"
    mongodb_user: str = "user"
    mongodb_pass: str = "pass"
    mongodb_auth_source: str = "admin"
    mongodb_auth_mechanism: str = "SCRAM-SHA-256"
    mongodb_direct_connection: str = "true"

    # Redis connection settings
    redis_host: str = "127.0.0.1"
    redis_port: int = 6379
    redis_db: int = 0
    redis_user: str = "root"
    redis_pass: str = "pass"

    # Cors settings
    cors_allow_origins: str = "*"
    cors_allow_methods: str = "*"
    cors_allow_headers: str = "*"
    cors_allow_credentials: bool = False
    cors_max_age: int = 86400

    # TrustedHostMiddleware settings
    trusted_hosts: str = "*"

    # GZipMiddleware settings
    gzip_min_length: int = 512

    # Loading .env file if present
    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"

# Load the settings
settings = Settings()

# initialize the fastapi app
app = FastAPI()

# setting up the CORS middleware with the list
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_allow_origins.split(','),
    allow_methods=settings.cors_allow_methods.split(','),
    allow_headers=settings.cors_allow_headers.split(',')
)

# add TrustedHostMiddleware with the list
app.add_middleware(TrustedHostMiddleware, allowed_hosts=settings.trusted_hosts.split(','))

# add GZipMiddleware
app.add_middleware(GZipMiddleware, minimum_size=settings.gzip_min_length)

# Set Logging basic config
logging.basicConfig(
    level=logging.DEBUG,
    format="%(levelname)s: %(asctime)s - %(message)s",

    handlers=[
        logging.StreamHandler()
    ]
)

logging.getLogger("uvicorn.access").setLevel(logging.WARNING)

@app.middleware("http")
async def log_requests(request: Request, call_next):
    start_time = time()

    # Call the next middleware or route handler
    response = await call_next(request)

    process_time = (time() - start_time) * 1000
    structured_log = {
        "method": request.method,
        "status_code": response.status_code,
        "path": request.url.path,
        "latency": f"{process_time:.2f}ms",
        "headers": {
            "request": dict(request.headers),
            "response": dict(response.headers),
        },
    }

    # Set log level
    if 400 <= response.status_code < 500:
        logging.warning(json.dumps(structured_log))
    elif response.status_code >= 500:
        logging.error(json.dumps(structured_log))
    else:
        logging.info(json.dumps(structured_log))

    return response

# MongoDB connection
mongo_uri = f"mongodb://{settings.mongodb_user}:{settings.mongodb_pass}@{settings.mongodb_host}:{settings.mongodb_port}/{settings.mongodb_db}?authSource={settings.mongodb_auth_source}&authMechanism={settings.mongodb_auth_mechanism}&directConnection={settings.mongodb_direct_connection}"
client = motor.motor_asyncio.AsyncIOMotorClient(
    mongo_uri, uuidRepresentation="standard"
)
db = client["auth"]

# Redis connection
redis_uri = f"redis://:{settings.redis_pass}@{settings.redis_host}:{settings.redis_port}/{settings.redis_db}"
redis = redis.asyncio.from_url(redis_uri, decode_responses=True)

# Define User model extending BeanieBaseUser and Document
class User(BeanieBaseUser, Document):
    pass

# Dependency for getting User Database
async def get_user_db():
    yield BeanieUserDatabase(User)

# User schemas for reading, creating, and updating users
class UserRead(schemas.BaseUser[PydanticObjectId]):
    # first_name: str
    # last_name: str
    # phone_number:str
    pass

class UserCreate(schemas.BaseUserCreate):
    # first_name: str
    # last_name: str
    # phone_number: Optional[str] 
    pass

class UserUpdate(schemas.BaseUserUpdate):
    # first_name: Optional[str]
    # last_name: Optional[str] 
    # phone_number: Optional[str]
    pass

# Secret for generating tokens
SECRET = "SECRET"

# Custom UserManager handling operations after registration, password reset, and verification
class UserManager(ObjectIDIDMixin, BaseUserManager[User, PydanticObjectId]):
    # Set the secrets for tokens
    reset_password_token_secret = SECRET
    verification_token_secret = SECRET

    # Actions to perform after a new user has registered
    async def on_after_register(self, user: User, request: Optional[Request] = None):
        # print(f"User {user.id} has registered.")
        
        # Log the user in after registration
        logging.debug(f"User {user.id} has registered.")

    # Actions to perform after a user has requested a password reset
    async def on_after_forgot_password(
        self, user: User, token: str, request: Optional[Request] = None
    ):
        print(f"User {user.id} has forgot their password. Reset token: {token}")

    # Actions to perform after a user has requested verification
    async def on_after_request_verify(
        self, user: User, token: str, request: Optional[Request] = None
    ):
        print(f"Verification requested for user {user.id}. Verification token: {token}")

# Dependency for getting User Manager
async def get_user_manager(user_db: BeanieUserDatabase = Depends(get_user_db)):
    yield UserManager(user_db)

# Transport mechanism for bearer token
bearer_transport = BearerTransport(tokenUrl="auth/login")

# Strategy for authentication - using JWT here
# def get_jwt_strategy() -> JWTStrategy:
#     return JWTStrategy(secret=SECRET, lifetime_seconds=3600)

# Strategy for authentication - using Redis here
def get_redis_strategy() -> RedisStrategy:
    return RedisStrategy(redis, lifetime_seconds=3600)

# Backend for authentication
auth_backend = AuthenticationBackend(
    name="redis",
    transport=bearer_transport,
    get_strategy=get_redis_strategy,
)

# FastAPI Users service with our custom User model and UserManager
fastapi_users = FastAPIUsers[User, PydanticObjectId](get_user_manager, [auth_backend])

# Middleware for ensuring the current user is active
current_active_user = fastapi_users.current_user(active=True)

# Including various routers for authentication, registration, password reset, verification and user management
app.include_router(
    fastapi_users.get_auth_router(auth_backend, requires_verification=False), prefix="/auth", tags=["auth"]
)
app.include_router(
    fastapi_users.get_register_router(UserRead, UserCreate),
    prefix="/auth",
    tags=["auth"],
)
app.include_router(
    fastapi_users.get_reset_password_router(),
    prefix="/auth",
    tags=["auth"],
)
app.include_router(
    fastapi_users.get_verify_router(UserRead),
    prefix="/auth",
    tags=["auth"],
)
app.include_router(
    fastapi_users.get_users_router(UserRead, UserUpdate),
    prefix="/user",
    tags=["user"],
)

# An authenticated route that greets the currently logged in user
@app.get("/authenticated-route")
async def authenticated_route(user: User = Depends(current_active_user)):
    return {"message": f"Hello {user.email}!"}

# Startup event to initialize Beanie (MongoDB ODM) with our User model
@app.on_event("startup")
async def on_startup():
    await init_beanie(
        database=db,
        document_models=[
            User,
        ],
    )

# Run the app using uvicorn when the script is run directly
if __name__ == "__main__":
    uvicorn.run(app, host=settings.app_host, port=settings.app_port)