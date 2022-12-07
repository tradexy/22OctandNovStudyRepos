#!bin/bash

aws sts get-caller-identity

docker build . -t hello-world:0.0.1

docker run \
    -p 9002:8080 \
    -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
    -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
    -e AWS_SESSION_TOKEN=$AWS_SESSION_TOKEN \
    -e AWS_REGION=$AWS_REGION \
    hello-world:0.0.1