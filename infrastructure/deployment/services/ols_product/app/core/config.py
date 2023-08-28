# app/core/config.py

from pydantic import BaseSettings

# BaseSettings
class Settings(BaseSettings):
    ## App
    app_host: str = "0.0.0.0"
    app_port: int = 8000
    app_log_level: str = "warning"

    ## MongoDB
    mongo_host: str = "127.0.0.1"
    mongo_port: int = 27017
    mongo_dbname: str = "product"
    mongo_user: str = "user"
    mongo_pass: str = "pass"
    mongo_auth_source: str = "admin"
    mongo_auth_mechanism: str = "SCRAM-SHA-256"
    mongo_direct_connection: str = "true"

    ## Redis
    redis_host: str = "127.0.0.1"
    redis_port: int = 6379
    redis_db: int = 0
    redis_user: str = "root"
    redis_pass: str = "pass"

    ## Cors
    cors_allow_origins: str = "*"
    cors_allow_methods: str = "*"
    cors_allow_headers: str = "*"
    cors_allow_credentials: bool = False
    cors_max_age: int = 86400

    ## TrustedHostMiddleware
    trusted_hosts: str = "*"

    ## GZipMiddleware
    gzip_min_length: int = 512

    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"

settings =  Settings()