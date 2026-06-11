#!/bin/bash
set -e
source ./variables.sh
source ./state.env
echo "Configuring EC2 Instance with AWS Credentials"
echo "INSTANCE_ID=$INSTANCE_ID"
echo "PUBLIC_IP=$PUBLIC_IP"
SSM_STATUS="Unknown"

for i in {1..30}; do
  SSM_STATUS=$(aws ssm describe-instance-information \
    --region "$AWS_REGION" \
    --filters "Key=InstanceIds,Values=$INSTANCE_ID" \
    --query 'InstanceInformationList[0].PingStatus' \
    --output text 2>/dev/null || true)

  if [ "$SSM_STATUS" = "Online" ]; then
    echo "SSM is online."
    break
  fi

  echo "SSM not ready yet. Current status: $SSM_STATUS"
  sleep 10
done

echo "Sending Minecraft setup commands"

COMMAND_ID=$(aws ssm send-command \
  --region "$AWS_REGION" \
  --instance-ids "$INSTANCE_ID" \
  --document-name "AWS-RunShellScript" \
  --comment "Install Docker and run Minecraft server" \
  --parameters 'commands=[
    "set -e",
    "sudo dnf update -y",
    "sudo dnf install -y docker",
    "sudo systemctl enable docker",
    "sudo systemctl start docker",
    "sudo docker rm -f minecraft || true",
    "sudo docker run -d --name minecraft -p 25565:25565 -e EULA=TRUE -e MEMORY=1G --restart unless-stopped itzg/minecraft-server",
    "sudo docker ps"
  ]' \
  --query 'Command.CommandId' \
  --output text)

echo "COMMAND_ID=$COMMAND_ID"

aws ssm wait command-executed \
  --region "$AWS_REGION" \
  --command-id "$COMMAND_ID" \
  --instance-id "$INSTANCE_ID" || true

aws ssm get-command-invocation \
  --region "$AWS_REGION" \
  --command-id "$COMMAND_ID" \
  --instance-id "$INSTANCE_ID" \
  --query '{Status:Status,StandardOutputContent:StandardOutputContent,StandardErrorContent:StandardErrorContent}' \
  --output text

echo
echo "Configuration script Successful."
