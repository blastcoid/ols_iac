## Profile Service

This is a microservice application built with Python 3.11, FastAPI, MongoDB, Redis, and GraphQL. It provides API endpoints to manage profiles and categories, and has been designed using the clean architecture principles.

### Features

- List, create, update, and delete profiles
- List, create, update, and delete address
- Data persistence using MongoDB
- Caching using Redis
- Error handling and logging
- CORS (Cross-Origin Resource Sharing) support
- GZip compression middleware
- Dockerized application for easy deployment
- **GraphQL API** for flexible data querying and mutations
- **Clean Architecture Design** ensuring separation of concerns and scalability
- **GraphQL Resolvers** for handling profile-related queries and mutations
- **Event Handlers** for managing domain events and integrations

### Prerequisites

Make sure you have the following installed on your system:

- Docker
- Docker Compose

### Getting Started

Follow the steps below to get the microservice up and running:

1. Clone the repository:

   ```bash
   git clone https://github.com/ols_profile.git
   ```

2. Change into the project directory:

   ```bash
   cd profile-microservice
   ```

3. Build and run the Docker containers:

   ```bash
   docker-compose up --build -d
   ```

   This will build the Docker image and start the microservice, MongoDB, Redis, and GraphQL containers.

4. Access the microservice API:

   The microservice will be running at `http://localhost:8000/v1`.

### API Endpoints

The microservice provides the following API endpoints:

#### Products

- **GET /v1/profiles**: Retrieve a list of profiles.
- **GET /v1/profiles/{profile_id}**: Retrieve a specific profile by ID.
- **POST /v1/profiles**: Create a new profile.
- **PUT /v1/profiles/{profile_id}**: Update an existing profile.
- **DELETE /v1/profiles/{profile_id}**: Delete a profile.

#### GraphQL API

Access the GraphQL playground at `http://localhost:8000/graphql` to interact with the GraphQL API.

#### Request Headers

- **Authorization**: Bearer token for authentication. Include this header with each request that requires authentication.

#### Response Format

The API responses are in JSON format.

### API Documentation

To view the API documentation, access the Swagger UI at `http://localhost:8000/docs` or the ReDoc UI at `http://localhost:8000/redoc`. These UI interfaces provide detailed information about the available endpoints, request/response schemas, and allow you to interact with the API.

### Configuration

The microservice can be configured using environment variables. The configuration options are available in the `.env` file. Modify the values in this file to customize the application settings.

### Logging

The microservice logs are stored in the `logs` directory. Log files are created based on the date and time of the log entry.

### Troubleshooting

If you encounter any issues while running the microservice, please check the following:

- Ensure that Docker and Docker Compose are installed correctly.
- Check the container logs for any error messages.
- Verify that the required ports (`8000`, `27017`, `6379`) are not already in use on your system.

### Cleaning Up

To stop and remove the Docker containers, use the following command:

```bash
docker-compose down
```

This will stop and remove the containers, but keep the MongoDB data persistent.


### Acknowledgements

- This microservice was built using the FastAPI framework.
- MongoDB is used as the database for storing profiles and categories.
- Redis is used for caching data and improving performance.
- Docker and Docker Compose are used for containerization and easy deployment.
- **GraphQL** has been integrated to provide a flexible querying mechanism.
- **Clean Architecture** principles have been followed to ensure a maintainable and scalable application design.