#!/bin/bash

# Variables
RESOURCE_GROUP="house7-sec-lab-01"
LOCATION="centralus"
VNET_NAME="Lab01-VNet"
SUBNET_NAME="Lab01-Subnet"
NSG_NAME="Lab01-NSG"
PUBLIC_VM="TargetVM01"
PRIVATE_VM="TargetVM02"
VM_SIZE="Standard_B1s"
ADMIN_USERNAME="azureuser"
PASSWORD="Password123!"

# SSH Key
SSH_KEY_NAME="lab01_key"
PRIVATE_KEY_PATH="$HOME/.ssh/$SSH_KEY_NAME"
PUBLIC_KEY_PATH="$PRIVATE_KEY_PATH.pub"

if [ ! -f "$PRIVATE_KEY_PATH" ]; then
  ssh-keygen -t rsa -b 2048 -f "$PRIVATE_KEY_PATH" -q -N ""
fi

# Step 1: Create Resource Group
az group create --name $RESOURCE_GROUP --location $LOCATION

# Step 2: Create Virtual Network and Subnets
az network vnet create \
 --resource-group $RESOURCE_GROUP \
 --name $VNET_NAME \
 --address-prefix 10.0.0.0/16 \
 --subnet-name $SUBNET_NAME \
 --subnet-prefix 10.0.0.0/24

# Step 3: Create NSG and Allow SSH
az network nsg create \
 --resource-group $RESOURCE_GROUP \
 --name $NSG_NAME

az network nsg rule create \
 --resource-group $RESOURCE_GROUP \
 --nsg-name $NSG_NAME \
 --name Allow-SSH \
 --priority 1000 \
 --protocol Tcp \
 --direction Inbound \
 --source-address-prefixes '*' \
 --source-port-ranges '*' \
 --destination-address-prefixes '*' \
 --destination-port-ranges 22 \
 --access Allow

# Step 4: Associate NSG with Subnet
az network vnet subnet update \
 --resource-group $RESOURCE_GROUP \
 --vnet-name $VNET_NAME \
 --name $SUBNET_NAME \
 --network-security-group $NSG_NAME

# Step 5: Create Public VM (Compromised Target)
az vm create \
 --resource-group $RESOURCE_GROUP \
 --name $PUBLIC_VM \
 --image Ubuntu2404 \
 --admin-username $ADMIN_USERNAME \
 --authentication-type password \
 --admin-password $PASSWORD \
 --vnet-name $VNET_NAME \
 --subnet $SUBNET_NAME \
 --nsg $NSG_NAME \
 --public-ip-sku Standard \
 --size $VM_SIZE \

# Step 6: Create Private VM (Internal Target)
az vm create \
 --resource-group $RESOURCE_GROUP \
 --name $PRIVATE_VM \
 --image Ubuntu2404 \
 --admin-username $ADMIN_USERNAME \
 --authentication-type ssh \
 --ssh-key-values "$PUBLIC_KEY_PATH" \
 --vnet-name $VNET_NAME \
 --subnet $SUBNET_NAME \
 --public-ip-address "" \
 --size $VM_SIZE \

 # Step 7: Copy SSH Key to VM 01
VM01_PUBLIC_IP=$(az vm list-ip-addresses \
 --name $PUBLIC_VM \
 --resource-group $RESOURCE_GROUP \
 --query "[].virtualMachine.network.publicIpAddresses[0].ipAddress" \
 -o tsv)

sudo apt update -y
sudo apt install -y sshpass

# Ensure VM 01 is ready for SSH
echo "Waiting for VM to be ready..."
while ! sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 "$ADMIN_USERNAME@$VM01_PUBLIC_IP" "echo 'VM is ready'" &>/dev/null; do
  sleep 10
done
echo "VM is ready for SSH connections."

sshpass -p "$PASSWORD" scp "$PRIVATE_KEY_PATH" $ADMIN_USERNAME@$VM01_PUBLIC_IP:~/.ssh/key_to_the_boss_vm
sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no "$ADMIN_USERNAME@$VM01_PUBLIC_IP" << EOF
    chmod 600 ~/.ssh/key_to_the_boss_vm
EOF

echo "Lab setup complete."
echo "Here, have a public IP $VM01_PUBLIC_IP!"
