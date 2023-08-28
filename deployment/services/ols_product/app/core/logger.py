# app/core/logger.py

import uvicorn, logging

def configure_logger():
    logging.getLogger("uvicorn.access").setLevel(logging.CRITICAL)
    logger = logging.getLogger("fastapi")
    logger.setLevel(logging.DEBUG)
    ch = logging.StreamHandler()
    ch.setLevel(logging.DEBUG)
    formatter = logging.Formatter('%(levelprefix)s %(asctime)s %(message)s')
    FORMAT: str = "%(levelprefix)s %(asctime)s | %(message)s"
    formatter = uvicorn.logging.DefaultFormatter(FORMAT)
    ch.setFormatter(formatter)
    logger.addHandler(ch)

    return logger

log = configure_logger()
