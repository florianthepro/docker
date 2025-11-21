First download the script file [setup-minecraft-full.sh](https://florianthepro.github.io/docker/minecraft/setup-minecraft-full.sh) so that it is placed loosely in your Downloads folder on Windows.
>It should look like this: `C:\Users\<YourWindowsUser>\Downloads\setup-minecraft-full.sh`

Update and upgrade packages:

```
sudo apt update && sudo apt upgrade -y
```

Transfer the setup script from Windows to the Debian server (PowerShell on Windows):

```
scp $env:USERPROFILE\Downloads\setup-minecraft-full.sh <username>@<server-ip>:/home/<username>/
```

On the Debian server, make the script executable and run it:

```
chmod +x setup-minecraft-full.sh && ./setup-minecraft-full.sh
```

Install Playit (for tunneling/remote access):

```
sudo apt install gnupg -y && curl -SsL https://playit-cloud.github.io/ppa/key.gpg | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/playit.gpg >/dev/null && echo "deb [signed-by=/etc/apt/trusted.gpg.d/playit.gpg] https://playit-cloud.github.io/ppa/data ./" | sudo tee /etc/apt/sources.list.d/playit-cloud.list && sudo apt update && sudo apt install playit && playit
```

Start the Minecraft server with Docker Compose:

```
docker compose up -d
```
