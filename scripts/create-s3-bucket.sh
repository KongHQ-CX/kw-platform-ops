#!/bin/bash

set -e

# Define your bucket name and region
BUCKET_NAME=$1
AWS_REGION=${AWS_REGION}

echo "Using AWS region: $AWS_REGION"

# AWS_REGION, AWS_ACCESS_KEY_ID, and AWS_SECRET_ACCESS_KEY are expected to be set in the environment
if [ -z "$AWS_REGION" ] || [ -z "$AWS_ACCESS_KEY_ID" ] || [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
    echo "AWS_REGION, AWS_ACCESS_KEY_ID, and AWS_SECRET_ACCESS_KEY must be set."
    exit 1
fi

# Check if the bucket exists by listing it
if aws s3 ls "s3://$BUCKET_NAME" --region "$AWS_REGION" &> /dev/null; then
    echo "Bucket ${BUCKET_NAME} already exists."
    exit 0
else
    # Create the bucket if it does not exist
    aws s3 mb "s3://$BUCKET_NAME" --region "$AWS_REGION"
    if [ $? -eq 0 ]; then
        echo "Bucket ${BUCKET_NAME} created successfully."
        exit 0
    else
        echo "Failed to create bucket ${BUCKET_NAME}."
        exit 1
    fi
fi