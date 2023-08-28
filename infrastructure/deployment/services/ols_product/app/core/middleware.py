# app/core/middleware.py

import json, gzip, time
from fastapi import Request
from starlette.concurrency import iterate_in_threadpool
from starlette.middleware.base import BaseHTTPMiddleware
from .logger import log

## Logging Middleware
class LoggingMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request: Request, call_next):
        request.state.start_time = time.time()
        ### Call the next middleware or route handler
        response = await call_next(request)
        ### Calculate the request processing time    
        process_time = (time.time() - request.state.start_time) * 1000

        response_body = [chunk async for chunk in response.body_iterator]
        response.body_iterator = iterate_in_threadpool(iter(response_body))

        ### Decompress the response if it is gzip compressed
        if "gzip" in response.headers.get("Content-Encoding", ""):
            try:
                response_body_txt = gzip.decompress(response_body[0]).decode("utf-8")
                response_body_txt = json.loads(response_body_txt)
            except (gzip.BadGzipFile, json.JSONDecodeError) as e:
                log.warning("Failed to decompress or parse gzip response body: %s", str(e))
                response_body_txt = None
        else:
            if len(response_body) > 0:
                if response.headers.get("Content-Type", "") == "application/json":
                    response_body_txt = json.loads(response_body[0])
                else:
                    response_body_txt = response_body[0]
            else:
                response_body_txt = ""

        ### Set log level and format log accordingly
        if 400 <= response.status_code < 500:
            structured_log = {
                "method": request.method,
                "status_code": response.status_code,
                "path": request.url.path,
                "latency": f"{process_time:.2f}ms",
                "request": {
                    "headers": dict(request.headers),
                    # "body": dict(request.body()),
                },
                "response": {
                    "headers": dict(response.headers),
                    "body": response_body_txt,
                }    
            }
            log.warning(json.dumps(structured_log))
        elif 200<= response.status_code < 400:
            structured_log = {
                "method": request.method,
                "status_code": response.status_code,
                "path": request.url.path,
                "latency": f"{process_time:.2f}ms",
                "request": {
                    "headers": dict(request.headers),
                    # "body": dict(request.body()),
                },
                "response": {
                    "headers": dict(response.headers),
                    "body": response_body_txt,
                }    
            }
            log.info(json.dumps(structured_log))
        return response