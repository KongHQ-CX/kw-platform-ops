#!/bin/bash

set -e

# Define your bucket name and alias
ALIAS=$1
BUCKET_NAME=$2

echo "Using AWS endpoint URL: $AWS_ENDPOINT_URL"

# $AWS_ENDPOINT_URL $AWS_ACCESS_KEY_ID $AWS_SECRET_ACCESS_KEY are expected to be set in the environment
if [ -z "$AWS_ENDPOINT_URL" ] || [ -z "$AWS_ACCESS_KEY_ID" ] || [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
    echo "AWS_ENDPOINT_URL, AWS_ACCESS_KEY_ID, and AWS_SECRET_ACCESS_KEY must be set."
    exit 1
fi

# Set the MinIO client alias with S3v4 API
mc alias set $ALIAS $AWS_ENDPOINT_URL $AWS_ACCESS_KEY_ID $AWS_SECRET_ACCESS_KEY --api s3v4

# Check if the bucket exists
if mc ls "${ALIAS}/${BUCKET_NAME}" &> /dev/null; then
    echo "Bucket ${BUCKET_NAME} already exists."
    exit 0
else
    # Create the bucket if it does not exist
    mc mb "${ALIAS}/${BUCKET_NAME}"
    if [ $? -eq 0 ]; then
        echo "Bucket ${BUCKET_NAME} created successfully."
        exit 0
    else
        echo "Failed to create bucket ${BUCKET_NAME}."
        exit 1
    fi
fi