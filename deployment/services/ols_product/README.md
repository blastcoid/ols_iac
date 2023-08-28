## Product Microservice

This is a microservice application built with Python 3.11, FastAPI, MongoDB, and Redis. It provides API endpoints to manage products and categories.

### Features

- List, create, update, and delete products
- List, create, update, and delete categories
- Data persistence using MongoDB
- Caching using Redis
- Error handling and logging
- CORS (Cross-Origin Resource Sharing) support
- GZip compression middleware
- Dockerized application for easy deployment

### Prerequisites

Make sure you have the following installed on your system:

- Docker
- Docker Compose

### Getting Started

Follow the steps below to get the microservice up and running:

1. Clone the repository:

   ```bash
   git clone https://github.com/your-repository.git
   ```

2. Change into the project directory:

   ```bash
   cd product-microservice
   ```

3. Build and run the Docker containers:

   ```bash
   docker-compose up --build -d
   ```

   This will build the Docker image and start the microservice, MongoDB, and Redis containers.

4. Access the microservice API:

   The microservice will be running at `http://localhost:8000/v1`.

### API Endpoints

The microservice provides the following API endpoints:

#### Categories

- **GET /v1/categories**: Retrieve a list of categories.
- **GET /v1/categories/{category_id}**: Retrieve a specific category by ID.
- **POST /v1/categories**: Create a new category.
- **PUT /v1/categories/{category_id}**: Update an existing category.
- **DELETE /v1/categories/{category_id}**: Delete a category.

#### Products

- **GET /v1/products**: Retrieve a list of products.
- **GET /v1/products/{product_id}**: Retrieve a specific product by ID.
- **POST /v1/products**: Create a new product.
- **PUT /v1/products/{product_id}**: Update an existing product.
- **DELETE /v1/products/{product_id}**: Delete a product.

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

### License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

### Acknowledgements

- This microservice was built using the FastAPI framework.
- MongoDB is used as the database for

 storing products and categories.
- Redis is used for caching data and improving performance.
- Docker and Docker Compose are used for containerization and easy deployment.