# Online Shop Platform

Welcome to the Online Shop repository! This project is a personal endeavor aimed at creating an online shopping platform with a microservices architecture. Please note that this project is still under development and may undergo significant changes.

The repository is organized into two main directories: `infrastructure` and `services`.

## Infrastructure

The `infrastructure` directory contains the deployment configurations using Terraform for Google Cloud Platform (GCP). This ensures a seamless and scalable deployment of the entire platform on GCP.

## Services

The `services` directory contains the microservices that power the online shop. Each microservice has its own dedicated directory and README for more detailed information:

- **ols_auth**: Handles authentication for the platform. Built using FastAPI Users. [More details](services/ols_auth/README.md).
- **ols_product**: Manages the products available on the platform. [More details](services/ols_product/README.md).
- **ols_profile**: Manages user profiles and related functionalities. [More details](services/ols_profile/README.md).

### Quick Start

To get started with any of the microservices:

1. Navigate to the respective service directory.
2. Follow the instructions in the service-specific README.

## License

This project is licensed under the [Apache License](LICENSE).