# Overview

"Be The Hacker" is a series of hands-on labs designed to provide you with insight into how an attacker could exploit improperly secured environments. 

Through a series of scenarios, this lab series aims to teach the common mistakes made during cloud resource setup and demonstrate how they can be exploited by a bad actor.

By simulating real-world attacks on vulnerable systems, you'll gain practical experience in securing your own cloud infrastructure and understanding the importance of strong security practices.

# Prerequisites

Before starting these labs, please ensure you have the following:

- **Azure Subscription**: These labs will create resources in your Azure subscription. Make sure you have an active Azure subscription with appropriate permissions to create and manage resources.

- **Azure CLI Authentication**: You'll need to authenticate with Azure using the following commands:
  ```bash
  az login
  ```
  If not prompted to select a subscription, you may need to set the desired subscription using:
  ```bash
    az account set --subscription <subscription-id>
    ```

- **Script Dependencies**: Install the required tools for lab setup scripts:
  - **coreutils**:
    - Ubuntu/Debian: `sudo apt-get install coreutils`
    - CentOS/RHEL: `sudo yum install coreutils`
    - macOS: `brew install coreutils`
  - **sshpass**:
    - Ubuntu/Debian: `sudo apt-get install sshpass`
    - CentOS/RHEL: `sudo yum install sshpass`
    - macOS: `brew install hudochenkov/sshpass/sshpass`

# Lab 01: Compromised VM

## Scenario

You are Mr.Ton, first name Plank, and you aspire to create a popular fast food restaurant. You found the public ip for a machine in your  rival's restaurant. Try to gain access to their company secret!

## Setup Lab

You should first go through the `Lab 01` section in the presentation. After doing so, run the `lab_01_setup` script, but try not to read the script until after completing the lab so you don't ruin the *magic*.

```bash
cd Lab_01_Compromised_VM
./lab01_setup.sh
```

### Hard Mode

Go find the secret. Hopefully the powerpoint taught you something. Good luck.

### Guided Mode

Follow these [instructions](./Lab_01_Compromised_VM/guided_mode.md).
