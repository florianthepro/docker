How to Install Debian and Set Up a Minecraft Server

1. Install Debian 
- [Download ISO](https://github.com/florianthepro/docker/blob/main/minecraft/how-to-second.md)
- [Flash ISO to USB using](https://etcher.balena.io/#download-etcher)
- Boot from USB

Installation settings:
- Install
- Language: English
- Region: Other -> Europe -> Germany
- Keyboard layouts: de_de and US
- Timezone: Europe -> Berlin
- Partitioning: Guided – use entire disk with LVM, separate /home partition
- Desktop selection: uncheck Desktop Environment and GNOME, keep System Utilities

Important: Create two users during installation:
- root (random 20-character password)
- user (name of your choice, random 20-character password)

2. Post-Installation Setup
Log in as root and run:
sudo apt update
sudo apt upgrade
apt install sudo

Create user and add to sudo group:
useradd -m -s /bin/bash <username>
sudo usermod -aG sudo <username>
su - <username>

Install and enable SSH:
sudo apt install openssh-server
sudo systemctl enable ssh
sudo systemctl start ssh
ip a   (check IP address)

3. Use SSH from Windows
Open PowerShell and install OpenSSH client:
Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0

Connect to Debian:
ssh <username>@<ip-address>

Inside SSH:
sudo reboot now

Reconnect after reboot:
ssh <username>@<ip-address>

4. Install Docker
Inside SSH session:
sudo apt install curl
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
newgrp docker

5. Set Up Minecraft Server
Follow the instructions in the [how-to-second.md](https://github.com/florianthepro/docker/blob/main/minecraft/how-to-second.md)
