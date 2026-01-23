

```bash
TF_VARS="dev-chris"
terraform init -backend-config=tfvars/${TF_VARS}/backend.hcl

terraform plan -var-file="tfvars/${TF_VARS}/base.tfvars" -out="plan.tfplan"

terraform apply plan.tfplan

terraform output -raw mattermost_private_key > mattermost-key.pem

chmod 400 mattermost-key.pem

ssh -i "mattermost-key.pem" ec2-user@##.##.##.###

INSTANCE_NAME="mattermost-ec2-instance-chris-fickess-mattermost-191123"
INSTANCE_IP=$(aws ec2 describe-instances \
    --filters "Name=tag:Name,Values=${INSTANCE_NAME}" "Name=instance-state-name,Values=running" \
    --query "Reservations[0].Instances[0].PrivateIpAddress" \
    --output text)
echo "Instance IP: $INSTANCE_IP"



ssh -i "${HOME}/.ssh/test-mm-client-ec2" ec2-user@${INSTANCE_IP}



# testing
INSTANCE_ID=$(aws ec2 describe-instances \
    --filters "Name=tag:Name,Values=${INSTANCE_NAME}" "Name=instance-state-name,Values=running" \
    --query "Reservations[0].Instances[0].InstanceId" \
    --output text)

SG_ID=$(aws ec2 describe-instances \
    --instance-ids ${INSTANCE_ID} \
    --query "Reservations[].Instances[].SecurityGroups[].GroupId" \
    --output text)

SUBNET_ID=$(aws ec2 describe-instances \
    --filters "Name=tag:Name,Values=${INSTANCE_NAME}" "Name=instance-state-name,Values=running" \
    --query "Reservations[0].Instances[0].SubnetId" \
    --output text)
echo -e "${MAGENTA}SUBNET ID:${NC} ${SUBNET_ID}"

aws ec2 describe-network-acls --filters "Name=association.subnet-id,Values=${SUBNET_ID}"
100.99.157.87

aws ec2 describe-route-tables --filters "Name=association.subnet-id,Values=${SUBNET_ID}" \
    --query "RouteTables[].Routes[]" \
    --output table

aws ec2 describe-nat-gateways --nat-gateway-ids  \
    --query "NatGateways[].State"

aws ec2 describe-nat-gateways --query "NatGateways[].{ID:NatGatewayId,Subnet:SubnetId,State:State,ElasticIP:NatGatewayAddresses[0].PublicIp}" --output table | grep "${SUBNET_ID}"


aws ec2 describe-route-tables --filters "Name=association.subnet-id,Values=${SUBNET_ID}" --query "RouteTables[].Routes"