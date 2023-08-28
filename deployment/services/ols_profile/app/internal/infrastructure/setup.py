# app/internal/infrastructure/databases/mongo.py

import uvicorn, logging
from motor import motor_asyncio
from redis import asyncio as aioredis
from ...dependencies import get_settings

settings = get_settings()

# MongoDb
class Mongo:
    def __init__(self):
        ## Set mongo connection string
        self.uri = f"mongodb://{settings.mongo_user}:{settings.mongo_pass}@{settings.mongo_host}:{settings.mongo_port}/{settings.mongo_dbname}?authSource={settings.mongo_auth_source}&authMechanism={settings.mongo_auth_mechanism}&directConnection={settings.mongo_direct_connection}"
        self.client = motor_asyncio.AsyncIOMotorClient(self.uri)

    def getDb(self):
        ## Get database
        db = self.client[settings.mongo_dbname]
        return db
    
# Redis
class Redis:
    def __init__(self):
        ## Setup Redis connection string
        self.uri = f"redis://:{settings.redis_pass}@{settings.redis_host}:{settings.redis_port}/{settings.redis_db}"
        ### Set Redis TTL
        self.ttl = settings.redis_ttl

    def getClient(self):
        ## Connect to Redis
        client = aioredis.from_url(self.uri)
        return client    
    
    def getTtl(self):
        return self.ttl

class Logger:
    def __init__(self):
        logging.getLogger("uvicorn.access").setLevel(logging.CRITICAL)
        self.logger = logging.getLogger("fastapi")

    def getLogger(self):
        ## set fastapi log level
        self.logger.setLevel(logging.DEBUG)
        ## set stream handler
        ch = logging.StreamHandler()
        ch.setLevel(logging.DEBUG)
        ## set log format
        formatter = logging.Formatter('%(levelprefix)s %(asctime)s %(message)s')
        FORMAT: str = "%(levelprefix)s %(asctime)s | %(message)s"
        ## set Uvicorn default log format
        formatter = uvicorn.logging.DefaultFormatter(FORMAT)
        ch.setFormatter(formatter)
        self.logger.addHandler(ch)
        return self.logger

log = Logger().getLogger()