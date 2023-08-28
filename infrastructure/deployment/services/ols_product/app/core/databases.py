# app/core/databases.py

from motor import motor_asyncio
from redis import asyncio as aioredis
from .config import settings

# MongoDb
class MongoDb:
    def __init__(self):
        ## MongoDB connection string
        mongo_uri = f"mongodb://{settings.mongo_user}:{settings.mongo_pass}@{settings.mongo_host}:{settings.mongo_port}/{settings.mongo_dbname}?authSource={settings.mongo_auth_source}&authMechanism={settings.mongo_auth_mechanism}&directConnection={settings.mongo_direct_connection}"
        ### create mongo client
        self.client = motor_asyncio.AsyncIOMotorClient(mongo_uri)
        ### Access database
        self.db = self.client[settings.mongo_dbname]

# Redis
class Redis:
    def __init__(self):
        ## Redis connection string
        redis_uri = f"redis://:{settings.redis_pass}@{settings.redis_host}:{settings.redis_port}/{settings.redis_db}"
        ### Connect to Redis
        self.redis = aioredis.Redis.from_url(redis_uri, decode_responses=True)

mongo_client = MongoDb().client
db = MongoDb().db
redis = Redis().redis