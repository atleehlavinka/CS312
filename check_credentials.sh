#!/bin/bash
set -e
source ./variables.sh
echo "Check AWS Credentials"
aws sts get-caller-identity
echo "Check AWS region"
aws configure get region
