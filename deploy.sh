#!/bin/sh

## SET VARS

source ./set_ms_id.sh

MS_NAME="${MS_ID}-ms"
PROJECT="nw-app"

ENV=$1
ENV_SUFFIX="-$ENV"
DEV=dev
STAGING=staging
PROD=prod

ECS_CLUSTER="${PROJECT}${ENV_SUFFIX}-cluster"

if [ "$ENV" != "$DEV" ] && [ "$ENV" != "$STAGING" ] && [ "$ENV" != "$PROD" ]; then
    echo "$ENV is invalid - allowed values are dev, staging, prod. "
    echo "Setting ENV=$DEV"
    ENV=$DEV
fi

if [ "$ENV" = "$PROD" ]; then
    ENV_SUFFIX=""
    ECS_CLUSTER=$PROJECT
fi

echo "Deploying ${PROJECT} ${MS_NAME} on ${ENV} environment"

AWS_IAM_INFO=`aws sts get-caller-identity`
TIMESTAMP=`date +"D%d-%M-%Y-T%I-%M-%PM-%s"`
TIME=`date +"%s"`
RELEASE_ID="${VERSION}-${TIME}"
ACCOUNT_ID=$(jq -r '.Account' <<< ${AWS_IAM_INFO})
IMAGE=${MS_NAME}-${PROJECT}${ENV_SUFFIX}
REGISTRY=${ACCOUNT_ID}.dkr.ecr.ap-south-1.amazonaws.com/${MS_NAME}-${PROJECT}${ENV_SUFFIX}


deploy_latest() {
    docker build -t ${IMAGE} . --build-arg BUILD_ENV=${ENV} &&
    docker tag ${IMAGE}:latest ${REGISTRY}:latest &&
    docker tag ${IMAGE}:latest ${REGISTRY}:${RELEASE_ID} &&
    echo "ECR: PUSH" &&
    docker push ${REGISTRY}:latest &&
    docker push ${REGISTRY}:${RELEASE_ID} &&
    echo "ECS: DEPLOYMENT SERVICE TO CLUSTER: $ECS_CLUSTER" &&
    aws ecs update-service --cluster ${ECS_CLUSTER} --service ${MS_NAME}-deployment-service --force-new-deployment
}

push_release() {
    docker build --no-cache -t ${IMAGE} . --build-arg=${ENV} &&
    docker tag ${IMAGE}:latest ${REGISTRY}:${RELEASE_ID} &&
    echo "ECR: PUSH" &&
    docker push ${REGISTRY}:${RELEASE_ID}
}


echo "BUILD: GRADLE" &&
./gradlew build &&
deploy_latest