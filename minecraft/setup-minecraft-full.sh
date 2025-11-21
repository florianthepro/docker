#!/bin/bash
set -e

USER_NAME=$(whoami)
HOME_DIR=$(eval echo "~$USER_NAME")
BASE_DIR="$HOME_DIR/minecraft"

mkdir -p "$BASE_DIR"
cd "$BASE_DIR"

echo "===== Minecraft Setup Script ====="

read -p "Maximum number of players (e.g. 50): " MAX_PLAYERS
read -p "RAM limit (e.g. 6G): " MEMORY
read -p "RCON password: " RCON_PASSWORD
read -p "Enable backup? (yes/no): " BACKUP
read -p "Enable update? (yes/no): " UPDATE
echo "Choose server type: 1=Java, 2=Bedrock, 3=Both"
read -p "Your choice: " SERVER_TYPE
read -p "Enable voice chat? (yes/no): " VOICECHAT
read -p "Enable query? (yes/no): " QUERY
read -p "MOTD text: " MOTD
read -p "OP player name: " OP_NAME
read -p "Render distance (chunks around player, e.g. 10): " RENDERDISTANCE

PORTS="- \"25565:25565\""
if [ "$SERVER_TYPE" == "2" ] || [ "$SERVER_TYPE" == "3" ]; then
  PORTS="$PORTS\n      - \"19132:19132/udp\""
fi
if [ "$VOICECHAT" == "yes" ]; then
  PORTS="$PORTS\n      - \"24454:24454/udp\""
fi
PORTS="$PORTS\n      - \"25575:25575\""

cat > docker-compose.yml <<EOF
services:
  mc-server:
    image: itzg/minecraft-server
    container_name: mc-crossplay
    ports:
$PORTS
    environment:
      EULA: "TRUE"
      TYPE: "PAPER"
      MAX_PLAYERS: "$MAX_PLAYERS"
      MEMORY: "$MEMORY"
      ENABLE_RCON: "true"
      RCON_PASSWORD: "$RCON_PASSWORD"
    volumes:
      - ./data:/data
      - ./backups:/backups
    restart: unless-stopped
EOF

if [ "$BACKUP" == "yes" ]; then
cat >> docker-compose.yml <<EOF

  backup:
    image: alpine
    container_name: mc-backup
    volumes:
      - ./data:/data
      - ./backups:/backups
    entrypoint: >
      sh -c "crond -f -l 2"
    restart: unless-stopped
    configs:
      - source: backup-cron
        target: /etc/crontabs/root
EOF

cat > backup-cron <<EOF
0 11 * * SUN tar -czf /backups/mc-\$(date +\%F).tar.gz /data
0 12 * * WED tar -czf /backups/mc-\$(date +\%F).tar.gz /data
EOF
fi

if [ "$UPDATE" == "yes" ]; then
cat >> docker-compose.yml <<EOF

  updater:
    image: alpine
    container_name: mc-updater
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - ./update.sh:/update.sh
    entrypoint: >
      sh -c "crond -f -l 2"
    restart: unless-stopped
    configs:
      - source: update-cron
        target: /etc/crontabs/root
EOF

cat > update-cron <<EOF
0 12 * * SUN /update.sh
EOF

cat > update.sh <<'EOF'
#!/bin/sh
PLAYERS=$(mcstatus mc-server status | grep 'players' | awk '{print $2}')
if [ "$PLAYERS" -eq 0 ]; then
  echo "No players online – update will be performed..."
  docker-compose down
  docker-compose pull
  docker-compose up -d
else
  echo "Players online – update postponed."
fi
EOF
chmod +x update.sh
fi

cat > update-plugins.sh <<'EOF'
#!/bin/sh
PLUGIN_DIR="./data/plugins"
mkdir -p "$PLUGIN_DIR"
echo "==> Downloading latest plugins..."
echo "-> Geyser-Spigot"
curl -L -o "$PLUGIN_DIR/Geyser-Spigot.jar" \
  https://ci.opencollab.dev/job/GeyserMC/job/Geyser/job/master/lastSuccessfulBuild/artifact/bootstrap/spigot/target/Geyser-Spigot.jar
echo "-> Floodgate"
curl -L -o "$PLUGIN_DIR/Floodgate.jar" \
  https://ci.opencollab.dev/job/GeyserMC/job/Floodgate/job/master/lastSuccessfulBuild/artifact/spigot/target/Floodgate-Spigot.jar
echo "-> Simple Voice Chat"
curl -L -o "$PLUGIN_DIR/voicechat.jar" \
  https://modrinth.com/plugin/simple-voice-chat/version/latest/download
echo "==> Done! Plugins are now in $PLUGIN_DIR"
EOF
chmod +x update-plugins.sh

mkdir -p data
cat > data/server.properties <<EOF
motd=$MOTD
enable-query=$([ "$QUERY" == "yes" ] && echo "true" || echo "false")
view-distance=$RENDERDISTANCE
EOF

echo "===== Setup complete ====="
echo "Start server with: docker compose up -d"
echo "Internal availability:"
echo "Java port: 25565"
if [ "$SERVER_TYPE" == "2" ] || [ "$SERVER_TYPE" == "3" ]; then
  echo "Bedrock port: 19132/udp"
fi
if [ "$VOICECHAT" == "yes" ]; then
  echo "Voice Chat port: 24454/udp"
fi
echo "RCON port: 25575"
echo "OP player: $OP_NAME"
