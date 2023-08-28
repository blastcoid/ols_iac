# app/internal/infrastructure/event_handlers.py

from fastapi import HTTPException, status
from ...internal.config import Settings
from .setup import Mongo, Redis

settings = Settings()
db = Mongo().getDb()
redis_client = Redis().getClient()

async def startup_event_handler():
    ### create Profile collections
    try:
      profile_collection = db["Profile"]
      await profile_collection.create_index("userId", unique=True)
    except Exception as e:
        raise HTTPException(
          status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, 
          detail= {
            "msg": "Error while creating index for Profile collection",
            "reason": str(e)
          }
        )

async def shutdown_event_handler():
    # Close redis connection
    try:
      await redis_client.close()
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, 
            detail= {
              "msg": "Error while closing mongo and redis connection",
              "reason": str(e)
            }
          )
