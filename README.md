# CS312 - Course Project Part 2

This project will configure automated setup scripts for setting up a publicly accessible Minecraft server.

## Project Files

The project folder should contain the following files:

```text
variables.sh
check_credentials.sh
provision.sh
configure.sh
verify.sh
```

And create this file:

```text
state.env
```

## Create the Project Folder

Create a folder for the project:

```bash
mkdir -p ~/minecraft-aws
cd ~/minecraft-aws
```

Place the files from this project into that folder.

Make the scripts executable:

```bash
chmod +x check_credentials.sh
chmod +x provision.sh
chmod +x configure.sh
chmod +x verify.sh
```

## Run the Setup

### 1. Check Credentials

```bash
bash check_credentials.sh
```

This verifies that the AWS CLI is authenticated and using the correct region. If this is not working, please review the AWS documentation for accessing the AWS CLI.

### 2. Provision the EC2 Instance

```bash
bash provision.sh
```

This script creates the AWS resources needed for the Minecraft server. These include the EC2 instance, security group, network setup, and finding the public IP address. When the setup completes, it creates and outputs the instance information to state.env.

### 3. Configure the Minecraft Server

```bash
bash configure.sh
```

This installs Docker and starts the Minecraft server container. You can run this command again without destroying the old container and outputs docker info.

### 4. Verify the Minecraft Server

```bash
bash verify.sh
```

This script checks whether the Minecraft server is reachable on TCP port `25565`. The output should indicate 

After reaching this part of the setup, you have successfully created your own Minecraft server!
