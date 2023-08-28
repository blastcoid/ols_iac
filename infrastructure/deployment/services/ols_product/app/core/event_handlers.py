# app/api/v1/core/event_handlers.py
from .logger import log
from .databases import mongo_client, db, redis

## Startup event handler
async def startup_event_handler():
    ### create Category collections
    category_collection = db["Category"]
    await category_collection.create_index("_id")
    await category_collection.create_index("name", unique=True)
    ### create Product collections
    product_collection = db["Product"]
    await product_collection.create_index("_id")
    await product_collection.create_index("sku", unique=True)
    await product_collection.create_index("name", unique=True)

## Shutdown event handler
async def shutdown_event_handler():
    # Close mongo & connection
    log.debug("Closing mongo and redis connection")
    mongo_client.close()
    await redis.close()
