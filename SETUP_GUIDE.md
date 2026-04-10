# Geyser Docker Setup Guide

This guide walks you through setting up and running Geyser in Docker to bridge Bedrock and Java Edition Minecraft servers.

## Prerequisites

- Docker installed (version 19.03 or later)
- A Java Edition Minecraft server running and accessible
- Port 19132 (UDP) available on your host
- 2-4 GB RAM available for the container

## Step 1: Clone or Download This Repository

```bash
cd /path/to/geyser-broadcast
```

## Step 2: Build the Docker Image

```bash
docker build -t geyser-mc:latest .
```

This will:
- Download Eclipse Temurin 21 JDK Alpine base image
- Install dependencies (curl, bash)
- Download the latest Geyser standalone JAR
- Create necessary directories
- Set up the startup script

## Step 3: Configure Geyser

Copy the example configuration and edit it:

```bash
cp geyser-config-example.yml my-geyser-config.yml
nano my-geyser-config.yml
```

**Key configuration options:**

- `bedrock.address` - Set to `0.0.0.0` (listen on all interfaces)
- `bedrock.port` - 19132 (standard Bedrock port, usually don't change)
- `remote.address` - IP/hostname of your Java Edition server
- `remote.port` - Port of your Java Edition server (default 25565)
- `remote.auth-type` - `online` or `offline` depending on your Java server
- `xbox-authentication` - Set to `false` if you don't need Xbox Live auth

Example for local Java server:

```yaml
bedrock:
  address: 0.0.0.0
  port: 19132

remote:
  address: localhost        # or your server IP
  port: 25565
  auth-type: online         # change to 'offline' if needed

info:
  motd1: "My Geyser Server"
  motd2: "Join with Bedrock"
  level-name: "My World"
```

## Step 4: Run the Container

### Basic Command

```bash
docker run -d \
  --name geyser-server \
  -p 19132:19132/udp \
  -v geyser-data:/geyser/data \
  -v geyser-config:/geyser/config \
  -v /path/to/my-geyser-config.yml:/geyser/config/geyser-config.yml \
  -v geyser-plugins:/geyser/plugins \
  --memory=2g \
  geyser-mc:latest
```

### Advanced Command with More Options

```bash
docker run -d \
  --name geyser-server \
  -p 19132:19132/udp \
  -v geyser-data:/geyser/data \
  -v geyser-config:/geyser/config \
  -v /path/to/my-geyser-config.yml:/geyser/config/geyser-config.yml \
  -v geyser-plugins:/geyser/plugins \
  -e JVM_OPTS="-Xms2048M -Xmx4096M" \
  --memory=4g \
  --cpus="2" \
  --restart=unless-stopped \
  geyser-mc:latest
```

### With Docker Compose

Create `docker-compose.yml`:

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
      - ./my-geyser-config.yml:/geyser/config/geyser-config.yml
      - geyser-plugins:/geyser/plugins
    environment:
      JVM_OPTS: "-Xms2048M -Xmx4096M"
    memory: 4g
    restart: unless-stopped

volumes:
  geyser-data:
  geyser-config:
  geyser-plugins:
```

Then run:
```bash
docker-compose up -d
docker-compose logs -f
```

## Step 5: Verify the Server is Running

```bash
# Check container status
docker ps | grep geyser

# View logs
docker logs geyser-server

# Look for this line:
# [HH:MM:SS INFO] Started Geyser on UDP port 19132
```

## Step 6: Connect with Bedrock Edition

### On the Same Network

1. Open Minecraft Bedrock Edition
2. Go to **Servers** tab
3. Click **Add Server**
4. Enter:
   - **Server Name**: "Geyser Server"
   - **Server Address**: `<your-docker-host-ip>`
   - **Port**: `19132`
   - **Leave online mode unchecked** (unless using Xbox auth)
5. Click **Add**
6. Select the server and click **Join**

### From a Different Network

You'll need to:
1. Set up port forwarding on your router to forward UDP 19132 to your Docker host
2. Or use a service like ngrok or ZeroTier for networking
3. Then use your external IP/hostname instead of local IP

## Step 7: (Optional) MCXboxBroadcast Configuration

MCXboxBroadcast extension is **already pre-installed** in this image. On first run, you'll need to authenticate:

1. Start the container:
   ```bash
   docker run -it --name geyser-server -p 19132:19132/udp geyser-mc:latest
   ```

2. Look for the authentication prompt:
   ```
   [INFO] [mcxboxbroadcast] To sign in, use a web browser to open the page https://www.microsoft.com/link and enter the code XXXXXXXX to authenticate.
   ```

3. Open the link in a web browser and follow the authentication steps

4. Once authenticated, the extension will manage your Xbox Live presence

For more details on MCXboxBroadcast features, see: https://github.com/MCXboxBroadcast/Broadcaster

## Maintenance

### View Logs
```bash
docker logs geyser-server -f              # Follow logs in real-time
docker logs geyser-server --tail 100      # Last 100 lines
```

### Stop Server
```bash
docker stop geyser-server
```

### Start Server
```bash
docker start geyser-server
```

### Restart Server
```bash
docker restart geyser-server
```

### Update Geyser
```bash
docker pull geysermc/geyser  # If using official image
docker build -t geyser-mc:latest .       # Rebuild from Dockerfile
docker stop geyser-server
docker rm geyser-server
# Re-run container with new image
```

### Backup Data

```bash
# Backup volumes
docker run --rm -v geyser-data:/data -v $(pwd):/backup \
  alpine tar czf /backup/geyser-data-backup.tar.gz -C /data .

# Restore volumes
docker run --rm -v geyser-data:/data -v $(pwd):/backup \
  alpine tar xzf /backup/geyser-data-backup.tar.gz -C /data
```

### Monitor Resource Usage
```bash
docker stats geyser-server
```

## Troubleshooting

### Server won't start

Check logs for errors:
```bash
docker logs geyser-server
```

Common issues:
- **Out of memory**: Increase with `--memory` flag
- **Port in use**: Change port mapping with `-p NEW_PORT:19132/udp`
- **Disk space**: Check with `df -h`

### Bedrock clients can't connect

1. **Check port is exposed:**
   ```bash
   docker port geyser-server
   ```
   Should show: `19132/udp -> 0.0.0.0:19132`

2. **Check container is running:**
   ```bash
   docker ps | grep geyser
   ```

3. **Check logs for startup message:**
   ```bash
   docker logs geyser-server | grep "Started Geyser"
   ```

4. **Verify Java server is reachable:**
   ```bash
   docker exec geyser-server ping <java-server-ip>
   ```

5. **Check firewall:**
   - Allow UDP port 19132
   - On Linux: `sudo ufw allow 19132/udp`

### Connection refused from Java server

Check your `geyser-config.yml`:
```yaml
remote:
  address: your-java-server-ip
  port: 25565
```

Make sure:
- IP address is correct (not `localhost` if running in Docker)
- Port matches your Java server's port
- Java server is running and accessible from Docker container

### High CPU usage

1. Check Geyser logs for errors
2. Reduce simulation distance in config
3. Check Java server performance
4. Monitor with: `docker stats geyser-server`

### Plugin not loading

1. Verify JAR is in plugins directory:
   ```bash
   docker exec geyser-server ls -la /geyser/plugins/
   ```

2. Check plugin compatibility with Geyser version
3. Check logs for plugin errors:
   ```bash
   docker logs geyser-server | grep -i plugin
   ```

### SSL/TLS errors at startup

These are usually non-fatal and happen when Geyser can't reach:
- Minecraft services for encryption setup
- Update check servers
- Skin services

The server will still work. To suppress:
```yaml
metrics:
  enabled: false
```

## Getting Help

- [Geyser Discord](https://discord.gg/geysermc)
- [Geyser Documentation](https://geysermc.org/wiki/geyser/)
- [MCXboxBroadcast GitHub](https://github.com/MCXboxBroadcast/Broadcaster)
- Docker logs: `docker logs geyser-server`

## Next Steps

- Configure server.properties for your Java server
- Set up whitelist/ban list in geyser-config.yml
- Add resource packs
- Set up Floodgate for account linking
- Configure anti-cheat compatibility if needed
