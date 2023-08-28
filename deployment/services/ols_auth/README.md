# OLS Authentication Service

This service is responsible for handling authentication and user management for the Online Shop application. It's built using FastAPI and integrates with MongoDB for data storage and Redis for token management. Additionally, the service leverages **FastAPI Users**, a highly customizable authentication model, to manage user registration, authentication, and other related operations.

## Features

1. **User Registration**: Allows users to register with their email and password.
2. **User Authentication**: Authenticate users using bearer tokens.
3. **Password Reset**: Provides functionality for users to reset their forgotten passwords.
4. **User Verification**: Allows for email verification of registered users.
5. **User Management**: CRUD operations for user data.

## Technical Details

- **FastAPI**: A modern, fast web framework for building APIs with Python.
- **FastAPI Users**: An extensible authentication and user management library integrated with FastAPI. It provides tools and utilities for user registration, authentication, password reset, and more.
- **MongoDB**: Used as the primary database for storing user data.
- **Redis**: Used for storing authentication tokens.
- **Beanie**: An asynchronous Python Object-Document Mapper (ODM) for MongoDB, integrated with FastAPI.

## Files Overview

1. **main.py**: The main application file containing all the routes, middleware configurations, and database initializations.
2. **Dockerfile**: Contains instructions for building a Docker image of the service.
3. **requirements.txt**: Lists all the Python dependencies required for the service.
4. **.github/workflows/github-ci.yml**: GitHub Actions workflow for CI/CD, which builds and pushes Docker images.

## Deployment

The service can be containerized using Docker. Here's a brief overview of the Docker setup:

- Uses a multi-stage build to create a slimmer and safer image.
- The application runs on Python 3.11 with Alpine Linux for a minimal footprint.
- Dependencies are installed using pre-built wheels for faster build times.
- The application runs as a non-root user for added security.
- The service listens on port 8000.

To build and run the Docker container:

```bash
docker build -t ols_auth .
docker run -p 8000:8000 ols_auth
```

For CI/CD, the GitHub Actions workflow is set up to automatically build and push the Docker image to Docker Hub on every push to the `main` or `dev` branches and on new tags.

---

This README provides an overview of the `services/ols_auth` directory. For detailed configurations and customizations, refer to the respective files within the directory.

---