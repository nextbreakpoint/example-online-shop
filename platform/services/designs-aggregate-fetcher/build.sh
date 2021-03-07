#!/bin/sh
REPOSITORY=${1:-"nextbreakpoint"}
SERVICE_VERSION=${2:-"1.0.0"}
PLATFORM_VERSION=${3:-"1"}
docker build -t ${REPOSITORY}/designs-aggregate-fetcher:${SERVICE_VERSION}-${PLATFORM_VERSION} --build-arg github_username=${GITHUB_USERNAME} --build-arg github_password=${GITHUB_PASSWORD} .