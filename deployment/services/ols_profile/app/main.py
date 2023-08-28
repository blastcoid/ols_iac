# app/main.py

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.middleware.trustedhost import TrustedHostMiddleware
from fastapi.middleware.gzip import GZipMiddleware
from .internal.adapter.middleware import LoggingMiddleware
from .internal.adapter.error import http_exception_handler, server_error_exception_handler
from .internal.adapter.transport.http.profile_router import profile_http_router
from .internal.adapter.transport.graphql.profile_router import profile_gql_router
from .internal.config import get_settings
from .internal.infrastructure.event_handlers import startup_event_handler, shutdown_event_handler

settings = get_settings()

app = FastAPI()

app.include_router(profile_http_router)
app.include_router(profile_gql_router)

# Middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_allow_origins.split(','),
    allow_methods=settings.cors_allow_methods.split(','),
    allow_headers=settings.cors_allow_headers.split(',')
)
app.add_middleware(TrustedHostMiddleware, allowed_hosts=settings.trusted_hosts.split(','))
app.add_middleware(GZipMiddleware, minimum_size=settings.gzip_min_length)
app.add_middleware(LoggingMiddleware)

# Error Handlers
app.add_exception_handler(HTTPException, http_exception_handler)
app.add_exception_handler(Exception, server_error_exception_handler)

# Event handlers
app.add_event_handler("startup", startup_event_handler)
app.add_event_handler("shutdown", shutdown_event_handler)

# Run the FastAPI app
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host=settings.app_host, port=settings.app_port, log_level=settings.app_log_level)