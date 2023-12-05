#!/bin/bash

REPO_URL=$1
REPO_NAME=$2
EMR_RELEASE_LABEL=$3

echo "Building Docker image..."
docker build -t "${REPO_NAME}:latest" ./docker
if [ $? -ne 0 ]; then
    echo "Docker build failed"
    exit 1
fi

echo "Tagging Docker image..."
docker tag "${REPO_NAME}:latest" "${REPO_URL}:latest"
if [ $? -ne 0 ]; then
    echo "Docker tag failed"
    exit 1
fi

echo "Validating Docker image..."
if ! command -v amazon-emr-serverless-image &> /dev/null; then
  echo "Error: 'amazon-emr-serverless-image' command not found"
  exit 1
fi
amazon-emr-serverless-image \
    validate-image -r "$EMR_RELEASE_LABEL" -t spark \
    -i "${REPO_URL}:latest"
if [ $? -ne 0 ]; then
    echo "Image validation failed"
    exit 1
fi

echo "Logging into AWS ECR..."
aws ecr --profile="$AWS_PROFILE" get-login-password --region us-east-1 | docker login --username AWS --password-stdin "${REPO_URL%%/${REPO_NAME}*}"
if [ $? -ne 0 ]; then
    echo "ECR login failed"
    exit 1
fi

echo "Pushing image to ECR..."
docker push "${REPO_URL}:latest"
if [ $? -ne 0 ]; then
    echo "Docker push failed"
    exit 1
fi

echo "Build and deploy completed successfully"