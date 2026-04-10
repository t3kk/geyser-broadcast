# Volume Mounting Guide for Geyser Docker

This guide explains how to mount a persistent configuration directory to the Geyser Docker container.

## Overview

The Geyser Docker container expects a volume-mounted `/config` directory on your host. This directory should contain your `geyser-config.yml` and will receive extension data and player information that persists between container restarts.

```
Your Host                    Docker Container
-----------                  ----------------
/path/to/config/
  ├── geyser-config.yml   →  /config/geyser-config.yml
  ├── extensions/         →  /config/extensions/
  │   ├── MCXboxBroadcastExtension.jar   (copied by container)
  │   └── mcxboxbroadcast/               (extension data - persists)
  └── players/            →  /config/players/          (Geyser creates this)
```

## Initial Setup

### 1. Create Local Config Directory

```bash
# Create the config directory
mkdir -p /path/to/config/extensions

# Download the example config
curl -o /path/to/config/geyser-config.yml \
  https://raw.githubusercontent.com/GeyserMC/Geyser/master/bootstrap/standalone/src/main/resources/config.yml
```

Or copy from the provided example:

```bash
cp geyser-config-example.yml /path/to/config/geyser-config.yml
```

### 2. Customize geyser-config.yml

Edit `/path/to/config/geyser-config.yml` to match your setup:

```yaml
bedrock:
  address: 0.0.0.0
  port: 19132

remote:
  address: your-java-server.com  # Java Edition server
  port: 25565
  auth-type: online

info:
  motd1: "Your Server Name"
  motd2: "Line 2"
```

See the [Geyser Configuration Documentation](https://geysermc.org/wiki/geyser/getting-started/configuration/) for all options.

## Running the Container

### Docker CLI

```bash
docker run -d \
  --name geyser-broadcast \
  -p 19132:19132/udp \
  -v /path/to/config:/config \
  ghcr.io/t3kk/geyser-broadcast:latest
```

### Docker Compose

Create `docker-compose.yml`:

```yaml
version: '3.8'

services:
  geyser:
    image: ghcr.io/t3kk/geyser-broadcast:latest
    container_name: geyser-broadcast
    ports:
      - "19132:19132/udp"
    volumes:
      - ./config:/config
    restart: unless-stopped
    environment:
      - JAVA_OPTS=-Xms1024M -Xmx2048M
```

Then run:

```bash
docker-compose up -d
```

### Docker Swarm / Kubernetes

Mount the config volume at `/config` in the container specification.

## Directory Structure

Your local `/config` directory should look like this:

```
/config/
├── geyser-config.yml          ← User creates/configures
├── extensions/                ← Directory must exist
│   ├── MCXboxBroadcastExtension.jar   ← Container copies on each start
│   └── mcxboxbroadcast/               ← Created by extension, persists
│       ├── broadcast.conf
│       └── [other extension data]
└── players/                   ← Created by Geyser
    ├── [player data files]
    └── [permissions, etc.]
```

## Important Notes

### Initial Container Start

1. If `/config/extensions/` doesn't exist, the container will create it automatically
2. Geyser will create `geyser-config.yml` with defaults if not provided, but **we recommend pre-providing your config**
3. MCXboxBroadcast will create the `mcxboxbroadcast/` folder on first run

### Permissions

Ensure your local config directory has proper permissions:

```bash
# On Linux/Mac
chmod -R 755 /path/to/config

# If running as a specific user
sudo chown -R username:username /path/to/config
```

### Extension Updates

The MCXboxBroadcast extension JAR is **copied fresh from the image on every container start**. This ensures you always have the version that matches the image.

To update the extension version, pull the latest image:

```bash
docker pull ghcr.io/t3kk/geyser-broadcast:latest
docker-compose down
docker-compose up -d
```

### Persistence

These files persist between container restarts (stored in your local directory):

- `geyser-config.yml` - Your configuration (user-maintained)
- `extensions/mcxboxbroadcast/` - Extension data (created by extension)
- `players/` - Player authentication/permissions (created by Geyser)
- Any other data files Geyser creates

### Troubleshooting

**Container won't start:**
```bash
# Check logs
docker logs geyser-broadcast

# Verify config file exists
ls -la /path/to/config/geyser-config.yml
```

**Extension not loading:**
```bash
# Verify extension was copied
ls -la /path/to/config/extensions/MCXboxBroadcastExtension.jar

# Check container logs for extension errors
docker logs geyser-broadcast | grep -i broadcast
```

**Config not being read:**
- Ensure geyser-config.yml is at `/path/to/config/geyser-config.yml` (not in a subdirectory)
- Check file permissions: `ls -l /path/to/config/geyser-config.yml`

## Advanced: Pre-Seeding Config

To automate container setup, you can pre-create the entire config structure:

```bash
#!/bin/bash
CONFIG_DIR="/path/to/config"

# Create directories
mkdir -p "$CONFIG_DIR/extensions"
mkdir -p "$CONFIG_DIR/players"

# Copy config if not exists
if [ ! -f "$CONFIG_DIR/geyser-config.yml" ]; then
  cp geyser-config-example.yml "$CONFIG_DIR/geyser-config.yml"
fi

# Set permissions
chmod -R 755 "$CONFIG_DIR"

# Start container
docker-compose up -d
```

## Related Documentation

- [Geyser Configuration](https://geysermc.org/wiki/geyser/getting-started/configuration/)
- [MCXboxBroadcast Extension](https://github.com/MCXboxBroadcast/Broadcaster)
- [Docker Volumes Documentation](https://docs.docker.com/storage/volumes/)
