#!/bin/bash

# Variables
LOCATION="centralus"
VNET_NAME="Lab01-VNet"
SUBNET_NAME="Lab01-Subnet"
NSG_NAME="Lab01-NSG"
PUBLIC_VM="TheSpongeVM"
PRIVATE_VM="MrMoneyBagsVM"
VM_SIZE="Standard_B1s"
ADMIN_USERNAME="azureuser"

# Prompt for Resource Group Name
read -p "Enter the name of the resource group to create: " RESOURCE_GROUP

# Choose VM password
PASSWORD_FILE="common_passwords.txt"

PASSWORD=$(shuf "$PASSWORD_FILE" | while read -r password; do
  count=0
  [[ ${#password} -ge 12 ]] || continue 
  [[ "$password" =~ [A-Z] ]] && ((count++))
  [[ "$password" =~ [a-z] ]] && ((count++))
  [[ "$password" =~ [0-9] ]] && ((count++))
  [[ "$password" =~ [^a-zA-Z0-9] ]] && ((count++))
  
  if ((count >= 3)); then
    echo "$password"
    break
  fi
done)
echo "Selected password: $PASSWORD"


# SSH Key
SSH_KEY_NAME="lab01_key"
PRIVATE_KEY_PATH="$HOME/.ssh/$SSH_KEY_NAME"
PUBLIC_KEY_PATH="$PRIVATE_KEY_PATH.pub"

if [ ! -f "$PRIVATE_KEY_PATH" ]; then
  ssh-keygen -t rsa -b 2048 -f "$PRIVATE_KEY_PATH" -q -N ""
fi

# Step 1: Create Resource Group
az group create --name $RESOURCE_GROUP --location $LOCATION &> /dev/null

# Step 2: Create Virtual Network and Subnets
az network vnet create \
 --resource-group $RESOURCE_GROUP \
 --name $VNET_NAME \
 --address-prefix 10.0.0.0/16 \
 --subnet-name $SUBNET_NAME \
 --subnet-prefix 10.0.0.0/24 &> /dev/null

# Step 3: Create NSG and Allow SSH
az network nsg create \
 --resource-group $RESOURCE_GROUP \
 --name $NSG_NAME &> /dev/null

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
 --access Allow &> /dev/null

# Step 4: Associate NSG with Subnet
az network vnet subnet update \
 --resource-group $RESOURCE_GROUP \
 --vnet-name $VNET_NAME \
 --name $SUBNET_NAME \
 --network-security-group $NSG_NAME &> /dev/null

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
 --size $VM_SIZE &> /dev/null

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
 --private-ip-address "10.0.0.99" \
 --size $VM_SIZE &> /dev/null

 # Step 7: Copy things to the VMs
PUBLIC_VM_IP=$(az vm list-ip-addresses \
 --name $PUBLIC_VM \
 --resource-group $RESOURCE_GROUP \
 --query "[].virtualMachine.network.publicIpAddresses[0].ipAddress" \
 -o tsv) &> /dev/null

if ! command -v sshpass &> /dev/null; then
  echo "sshpass is not installed. Installing..."
  sudo apt update && sudo apt install -y sshpass
fi

# Ensure VM 01 is ready for SSH
echo "Waiting for VM to be ready..."
while ! sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 "$ADMIN_USERNAME@$PUBLIC_VM_IP" "echo 'VM is ready'" &>/dev/null; do
  sleep 10
done
echo "VM is ready for SSH connections."

sshpass -p "$PASSWORD" scp "$PRIVATE_KEY_PATH" $ADMIN_USERNAME@$PUBLIC_VM_IP:~/.ssh/key_to_the_boss_vm &> /dev/null
sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no "$ADMIN_USERNAME@$PUBLIC_VM_IP" &> /dev/null << EOF
chmod 600 ~/.ssh/key_to_the_boss_vm
ssh -i ~/.ssh/key_to_the_boss_vm -o StrictHostKeyChecking=no $ADMIN_USERNAME@10.0.0.99 << 'EOL'
echo "                                                                                                    
             _  __          _     _             ____       _   _                   
            | |/ /_ __ __ _| |__ | |__  _   _  |  _ \ __ _| |_| |_ _   _           
            |   /|  __/ _  |  _ \|  _ \| | | | | |_) / _  | __| __| | | |          
            |   \| | | (_| | |_) | |_) | |_| | |  __/ (_| | |_| |_| |_| |          
            |_|\_\_|  \__,_|_.__/|_.__/ \__, | |_|   \__,_|\__|\__|\__, |          
             ____                     _ |___/____                  |___/   _       
            / ___|  ___  ___ _ __ ___| |_  |  ___|__  _ __ _ __ ___  _   _| | __ _ 
            \___ \ / _ \/ __|  __/ _ \ __| | |_ / _ \|  __|  _   _ \| | | | |/ _  |
             ___) |  __/ (__| | |  __/ |_  |  _| (_) | |  | | | | | | |_| | | (_| |
            |____/ \___|\___|_|  \___|\__| |_|  \___/|_|  |_| |_| |_|\__,_|_|\__,_|                                                                                                                      
                                                                                       ...          
                                                                                     .+++++.        
                                                                                    :+++++++-.      
                                                                              .--..=+++++==++=.     
                                                                            .-=..-*+++===+++**+.    
                                                                            =:..:=+++++=++****:.    
                                                                            --.-=--++++++**+:.      
                                                                          .-=::-=--=+****=.         
                                                                        .:+:....-+==**=:==.         
                                                                       .+:....::::=-:::==+.         
                                                                     .=:.....::::==++=++:.          
                                                                   .=-.....::::==+=. .              
                                                                  =-......:::===+.                  
                                                     .:=+===+=-:=-:.....:::===+:                    
                                                  :==::.......:::::...:::===+:                      
                                               .:+::............:::::::-==+-                        
                                              :=:................:::::==++.                         
                                            -=::...........-==:::::::==+:.                          
                                          :=::..........:=-..:-=:::::===                            
                                       .:+::...........+:...::::=-:::==*.                           
                                      .+::...........+:...:::::::+:::==+:                           
                                    .=-:...........=-...::::::::::+:-==+:                           
                                  .=-:...........-=...:::::::::::=+-===+.                           
                                .==::..........-+....:::::::::::=+++==+:                            
                              .-=::..........:+:...:::::::::::-++**==+=.                            
                            .:=::...........=:...:::::::::::-+++**==+:                              
                           .=-:...........--....:::::::::-=+++*+==++.                               
                          =-:...........-=....:::::::-+++++*+====*:.                                
                        -=:...........:=:...:::::-=+++++=--====+=.                                  
                      :=::...........=:...:::-=++++++-:::====++.                                    
                    .+::..........-*=....::=++++*=:::::-====+:                                      
                  .=-:.........==-+....:-+++*+:::::::-====+-.                                       
                .-=:.......:=-:.-:...:=+++=:::::::::====+-.                                         
              .:=:......:=-....:...:-+++-:::::::::-===+=.                                           
             .+::....:+-..........-++*::::::::::-====+.                                             
           .=-:...:+-...........:=+*=:::::::::-====+:.                                              
          -=:...==............:-+++::::::::::====+:.                                                
        :+:..:+:............::=++-:::::::::====+-.                                                  
      .+-:.-=..............:-+++:::::::::-===+=.                                                    
     :=:.:=:.............::=+*-::::::::-===+=.                                                      
    .=:..=.............::-=+=:::::::::===+=.                                                        
    .=::.=...........::-+++:::::::::====+.                                                          
     -=:.:=........:::=++-::::::::====+:                                                            
      --:::=.....:::-++=::::::::-===+:                                                              
      .-=::.-=:---=+++::::::::-===+:                                                                
        .+:::::*+++*-:::::::-===+:                                                                  
         .--::::::::::::::====+-.                                                                   
           .==-:::::::-=====+-.                                                                     
              -+==========+=                                                                        
               ..=*+====+-.                                                                         
                    .::.                  
                              Congrats! You found it! "> ~/Krabs_Family_Secret.txt
EOL
EOF

echo "Lab setup complete."
echo "Here, have a public IP $PUBLIC_VM_IP!"
