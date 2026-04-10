# Geyser Docker with MCXboxBroadcast Extension

[![Build and Push Docker Image](https://github.com/USERNAME/geyser-broadcast/actions/workflows/build.yml/badge.svg)](https://github.com/USERNAME/geyser-broadcast/actions/workflows/build.yml)

A Docker container that runs [Geyser](https://geysermc.org/) Minecraft server with the [MCXboxBroadcast](https://github.com/MCXboxBroadcast/Broadcaster) extension **pre-installed**, enabling Xbox and other Bedrock Edition clients to connect to your Java Edition server with Xbox Live integration.

**Key Feature**: MCXboxBroadcast extension is built-in, so updates are as simple as pulling a new container image.

**Automated Builds**: This project uses GitHub Container Registry with automated weekly builds. Pre-built images are available - no need to build locally!

## Quick Start

### Option 1: Use Pre-Built Image (Recommended)

The fastest way - pull the latest pre-built image from GitHub Container Registry:

```bash
# Create config directory with your geyser-config.yml
mkdir -p ~/geyser-config
cp geyser-config-example.yml ~/geyser-config/geyser-config.yml

# Authenticate (one-time, if repository is private)
echo $GITHUB_TOKEN | docker login ghcr.io -u USERNAME --password-stdin

# Pull and run with config directory mounted
docker run -d \
  --name geyser-server \
  -p 19132:19132/udp \
  -v ~/geyser-config:/config \
  --memory=2g \
  ghcr.io/USERNAME/geyser-broadcast:latest
```

✅ **No build needed** - saves time and resources!

### Option 2: Build Locally

If you prefer to build the image yourself:

```bash
# Create config directory
mkdir -p ~/geyser-config
cp geyser-config-example.yml ~/geyser-config/geyser-config.yml

# Build
docker build -t geyser-mc:latest .

# Run with config directory mounted
docker run -d \
  --name geyser-server \
  -p 19132:19132/udp \
  -v ~/geyser-config:/config \
  --memory=2g \
  geyser-mc:latest
```

### View Logs

```bash
docker logs -f geyser-server
```

### Stop and Cleanup

```bash
docker stop geyser-server
docker rm geyser-server
```
```

## Configuration

### Volume Mounts

This container uses a single `/config` volume mount point for all persistent data:

```
/config/
├── geyser-config.yml         ← Your Geyser configuration
├── extensions/               ← MCXboxBroadcast extension (auto-copied from image)
│   ├── MCXboxBroadcastExtension.jar
│   └── mcxboxbroadcast/      ← Extension data (persists)
└── players/                  ← Player data and permissions
```

**See [VOLUME_SETUP.md](./VOLUME_SETUP.md) for detailed volume mounting instructions.**

### Quick Volume Mount Example

```bash
# Create config directory with your geyser-config.yml
mkdir -p ~/geyser-config
cp geyser-config-example.yml ~/geyser-config/geyser-config.yml

# Edit your config
nano ~/geyser-config/geyser-config.yml

# Run with mounted config
docker run -d \
  --name geyser-server \
  -p 19132:19132/udp \
  -v ~/geyser-config:/config \
  ghcr.io/USERNAME/geyser-broadcast:latest
```

### Geyser Configuration

The container reads `geyser-config.yml` from the mounted `/config` directory. 

To set up Geyser:

1. Start with the provided `geyser-config-example.yml`
2. Edit it with your Java server details (address, port, auth-type)
3. Mount it to the container at `/config/geyser-config.yml`

Example configuration:

```yaml
bedrock:
  address: 0.0.0.0
  port: 19132

remote:
  address: your-java-server.example.com
  port: 25565
  auth-type: online

info:
  motd1: "Geyser Server"
  motd2: "Bedrock to Java Edition"
```

For complete Geyser configuration options, see the [Geyser Documentation](https://geysermc.org/wiki/geyser/getting-started/configuration/).

### MCXboxBroadcast Extension

The MCXboxBroadcast extension is **pre-installed and automatically copied** from the image to `/config/extensions/` on each container start.

- Extension configuration: Check `~/geyser-config/extensions/mcxboxbroadcast/broadcast.conf` after first run
- Extension data persists in the mounted `/config` volume
- The extension jar is automatically updated when you pull a new container image

For MCXboxBroadcast setup, see the [MCXboxBroadcast Documentation](https://github.com/MCXboxBroadcast/Broadcaster).

## Exposed Ports

- **UDP 19132** - Bedrock Edition protocol (primary port for Bedrock clients)

To expose on a different host port:

```bash
docker run -d -p 19133:19132/udp geyser-mc:latest
```

Then connect Bedrock clients to `your-host-ip:19133`

## Memory Requirements

- **Minimum**: 1.5 GB RAM
- **Recommended**: 2-4 GB RAM
- **Large servers**: 4+ GB RAM

Adjust with the `-m` flag:

```bash
docker run -d -m 4g geyser-mc:latest
```

## Architecture

- **Base Image**: Eclipse Temurin 21 JDK Alpine (lightweight, secure, modern)
- **Geyser Version**: Latest standalone build (auto-downloaded during build via download.geysermc.org)
- **MCXboxBroadcast**: Pre-installed extension (latest from GitHub releases)
- **Extensions**: Located in `/geyser/extensions` (MCXboxBroadcast included)
- **Plugins**: Support for additional plugins via `/geyser/plugins`

## Automated Builds & Updates

This project uses **GitHub Actions** with **GitHub Container Registry (GHCR)** for continuous updates:

- 🔄 **Weekly builds** (Sundays at 00:00 UTC) check for new releases
- 📦 **Automatic updates** when any dependency releases a new version:
  - Eclipse Temurin LTS
  - GeyserMC
  - MCXboxBroadcast
- 🐳 **Pre-built images** available on GHCR - no build time required!
- 📌 **Version tracking** - image labels show exact versions used

### Using Pre-Built Images

Instead of building locally, simply pull:

```bash
```bash
docker pull ghcr.io/USERNAME/geyser-broadcast:latest
```

**For private repositories**, authenticate first:
```bash
echo $GITHUB_TOKEN | docker login ghcr.io -u USERNAME --password-stdin
docker pull ghcr.io/USERNAME/geyser-broadcast:latest
```

**For public repositories**, no authentication needed:
```bash
docker pull ghcr.io/USERNAME/geyser-broadcast:latest
```

See [REGISTRY_SETUP.md](./REGISTRY_SETUP.md) for complete details on GitHub Container Registry setup, making images public, and using pre-built images.

### Manual Rebuild

To force a rebuild even if versions haven't changed:
1. Go to your GitHub repository
2. Click **Actions** tab
3. Select **"Build and Push Docker Image"**
4. Click **"Run workflow"** → check **"Force build"** → **Run**

## Troubleshooting

### Container won't start
```bash
# Check logs
docker logs geyser-server

# Verify image built correctly
docker images | grep geyser-mc

# Check available disk space
df -h
```

### Bedrock clients can't connect
```bash
# Verify port is exposed
docker port geyser-server

# Check if port is in use
lsof -i :19132

# Verify Geyser startup message
docker logs geyser-server | grep "Started Geyser"

# Test connection from another host
nc -u <your-docker-host> 19132
```

### Performance issues
```bash
# Check resource usage
docker stats geyser-server

# Increase memory allocation
docker run -d -m 6g geyser-mc:latest

# Check CPU usage
top  # then find docker container PID
```

### Plugin not loading
```bash
# Verify MCXboxBroadcast is in the extensions directory
docker exec geyser-server ls -la /geyser/extensions/

# Check that extension JAR is valid
docker exec geyser-server file /geyser/extensions/*.jar

# Look for MCXboxBroadcast in logs
docker logs geyser-server | grep -i "mcxboxbroadcast\|Enabled extension"
```

### SSL/TLS errors at startup
These are typically non-fatal and occur when Geyser can't reach external services (update checks, encryption setup). The server will still function. If needed, you can disable them in `geyser-config.yml`:

```yaml
metrics:
  enabled: false
```

## Docker Compose Example

If you prefer docker-compose, create a `docker-compose.yml`:

```yaml
version: '3.8'

services:
  geyser:
    build: .
    image: geyser-mc:latest
    container_name: geyser-server
    ports:
      - "19132:19132/udp"
    volumes:
      - geyser-data:/geyser/data
      - geyser-config:/geyser/config
      - ./plugins:/geyser/plugins
    environment:
      JVM_OPTS: "-Xms2048M -Xmx4096M"
    memory: 4g
    restart: unless-stopped

volumes:
  geyser-data:
  geyser-config:
```

Then run with:
```bash
docker-compose up -d
docker-compose logs -f
```

## Resources

- [Geyser Wiki](https://geysermc.org/wiki/geyser/)
- [Geyser Configuration Guide](https://geysermc.org/wiki/geyser/Configuration/)
- [MCXboxBroadcast GitHub](https://github.com/MCXboxBroadcast/Broadcaster)
- [Bedrock to Java Connection](https://geysermc.org/wiki/geyser/How-to-Connect/)

## License

This Docker image is based on:
- **Geyser**: [GPL-3.0 License](https://github.com/GeyserMC/Geyser)
- **Eclipse Temurin**: [Eclipse Temurin Licensing](https://adoptopenjdk.net/about.html)
- **MCXboxBroadcast**: Check their repository for license information
