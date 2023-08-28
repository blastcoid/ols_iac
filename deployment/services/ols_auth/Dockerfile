# Use multi-stage builds for a slimmer and safer image
FROM python:3.11-alpine AS builder
WORKDIR /code
COPY ./requirements.txt /code/
# Add --no-cache to avoid cache creation by apk
RUN apk --no-cache add build-base && \
    pip3 wheel --no-cache-dir --wheel-dir /wheels -r requirements.txt

# Remove unnecessary packages after installation
RUN apk del build-base

# Second stage of the multi-stage build
FROM python:3.11-alpine
WORKDIR /code
COPY --from=builder /wheels /wheels
COPY --from=builder /code/requirements.txt .

# Install dependencies using pre-built wheels
RUN pip3 install --no-cache-dir --no-index --find-links=/wheels -r requirements.txt && \
    # Remove the wheels directory after use
    rm -rf /wheels

# Copy the application
COPY ./app /code/app

# Use a non-root user to run the application, which is safer
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser

# Expose application port
EXPOSE 8000

# CMD to run the application
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]