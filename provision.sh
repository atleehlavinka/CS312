#!/bin/bash
set -e
source ./variables.sh
echo "Using region: $AWS_REGION"
AMI_ID=$(aws ssm get-parameter --region "$AWS_REGION" --name /aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64 --query 'Parameter.Value' --output text)
echo "AMI_ID=$AMI_ID"
echo "Getting default VPC"
VPC_ID=$(aws ec2 describe-vpcs --region "$AWS_REGION" --filters "Name=is-default,Values=true" --query 'Vpcs[0].VpcId' --output text)
echo "VPC_ID=$VPC_ID"
SUBNET_ID=$(aws ec2 describe-subnets --region "$AWS_REGION" --filters "Name=vpc-id,Values=$VPC_ID" --query 'Subnets[0].SubnetId' --output text)
echo "SUBNET_ID=$SUBNET_ID"
echo "INSTANCE_PROFILE_NAME=$INSTANCE_PROFILE_NAME"
echo "Creating security group"
SECURITY_GROUP_ID=$(aws ec2 describe-security-groups --region "$AWS_REGION" --filters "Name=group-name,Values=$SECURITY_GROUP_NAME" "Name=vpc-id,Values=$VPC_ID" --query 'SecurityGroups[0].GroupId' --output text 2>/dev/null || true)
if [ "$SECURITY_GROUP_ID" = "None" ] || [ -z "$SECURITY_GROUP_ID" ]; then
  SECURITY_GROUP_ID=$(aws ec2 create-security-group --region "$AWS_REGION" --group-name "$SECURITY_GROUP_NAME" --description "Minecraft server security group" --vpc-id "$VPC_ID" --query 'GroupId' --output text)
fi
echo "SECURITY_GROUP_ID=$SECURITY_GROUP_ID"
echo "Allowing inbound Minecraft port 25565"
aws ec2 authorize-security-group-ingress --region "$AWS_REGION" --group-id "$SECURITY_GROUP_ID" --protocol tcp --port 25565 --cidr 0.0.0.0/0 2>/dev/null || echo "Port 25565 rule may already exist."
echo "Launching EC2 instance"
INSTANCE_ID=$(aws ec2 run-instances --region "$AWS_REGION" --image-id "$AMI_ID" --instance-type "$INSTANCE_TYPE" --iam-instance-profile Name="$INSTANCE_PROFILE_NAME" --security-group-ids "$SECURITY_GROUP_ID" --subnet-id "$SUBNET_ID" --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$PROJECT_NAME}]" --query 'Instances[0].InstanceId' --output text)
echo "INSTANCE_ID=$INSTANCE_ID"
aws ec2 wait instance-running --region "$AWS_REGION" --instance-ids "$INSTANCE_ID"
echo "Getting public IP"
PUBLIC_IP=$(aws ec2 describe-instances --region "$AWS_REGION" --instance-ids "$INSTANCE_ID" --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)
echo "PUBLIC_IP=$PUBLIC_IP"
cat > "$STATE_FILE" <<EOF
export INSTANCE_ID="$INSTANCE_ID"
export PUBLIC_IP="$PUBLIC_IP"
export AWS_REGION="$AWS_REGION"
EOF
echo "Provisioning complete! Congratulations"
echo "Instance ID: $INSTANCE_ID"
echo "Public IP: $PUBLIC_IP"
echo "Saved values to $STATE_FILE"
