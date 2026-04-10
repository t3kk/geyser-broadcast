# Quick Reference

## One-Liner Quick Start

```bash
docker run -d --name geyser -p 19132:19132/udp -v geyser-data:/geyser/data -v geyser-config:/geyser/config --memory=2g geyser-mc:latest
```

## Common Commands

### Build Image
```bash
docker build -t geyser-mc:latest .
```

### Run Container
```bash
# Basic
docker run -d --name geyser-server -p 19132:19132/udp geyser-mc:latest

# With volumes
docker run -d --name geyser-server \
  -p 19132:19132/udp \
  -v geyser-data:/geyser/data \
  -v geyser-config:/geyser/config \
  -v geyser-plugins:/geyser/plugins \
  geyser-mc:latest

# With custom config
docker run -d --name geyser-server \
  -p 19132:19132/udp \
  -v geyser-data:/geyser/data \
  -v ./geyser-config.yml:/geyser/config/geyser-config.yml \
  geyser-mc:latest
```

### View Logs
```bash
docker logs geyser-server              # Last logs
docker logs -f geyser-server           # Follow (tail -f)
docker logs --tail 50 geyser-server    # Last 50 lines
```

### Stop/Start
```bash
docker stop geyser-server
docker start geyser-server
docker restart geyser-server
```

### Remove Container
```bash
docker stop geyser-server
docker rm geyser-server
```

### List Volumes
```bash
docker volume ls | grep geyser
```

### Clean Up
```bash
docker stop geyser-server
docker rm geyser-server
docker volume rm geyser-data geyser-config geyser-plugins
```

## Configuration

### Point to Java Server
Edit `geyser-config.yml`:
```yaml
remote:
  address: your-server-ip    # or localhost
  port: 25565
  auth-type: online          # or offline
```

### Mount Config File
```bash
-v /path/to/geyser-config.yml:/geyser/config/geyser-config.yml
```

### Add Plugins
1. Download plugin JAR
2. Copy to plugins directory:
   ```bash
   cp plugin.jar /path/to/plugins/
   ```
3. Mount plugins:
   ```bash
   -v /path/to/plugins:/geyser/plugins
   ```

### Adjust Memory
```bash
docker run -d -m 4g geyser-mc:latest   # 4GB
docker run -d --memory=2g geyser-mc:latest  # 2GB
```

## Troubleshooting Checklist

- [ ] Container running: `docker ps | grep geyser`
- [ ] Port exposed: `docker port geyser-server`
- [ ] Check logs: `docker logs geyser-server`
- [ ] Look for: `Started Geyser on UDP port 19132`
- [ ] Java server reachable: Check `remote.address` in config
- [ ] Firewall: UDP 19132 open
- [ ] Disk space: `df -h`
- [ ] Memory: `docker stats geyser-server`

## Port Mapping Reference

### Default (localhost only)
```bash
-p 19132:19132/udp    # Access from: 127.0.0.1:19132
```

### All interfaces
```bash
-p 0.0.0.0:19132:19132/udp    # Access from: any-ip:19132
```

### Custom port mapping
```bash
-p 19133:19132/udp    # Access from: host-ip:19133
```

## Volume Mounting

| Path | Purpose |
|------|---------|
| `/geyser/data` | Worlds, player data, cache |
| `/geyser/config` | Configuration files |
| `/geyser/plugins` | Server plugins |

### Example: Mount all volumes
```bash
-v geyser-data:/geyser/data \
-v geyser-config:/geyser/config \
-v geyser-plugins:/geyser/plugins
```

## File Structure

```
geyser-broadcast/
├── Dockerfile                 # Docker build file
├── README.md                  # Main documentation
├── SETUP_GUIDE.md            # Step-by-step setup
├── QUICK_REFERENCE.md        # This file
├── .gitignore                # Git ignore rules
├── geyser-config-example.yml # Example Geyser config
└── server-properties-example # Example server properties
```

## Docker Compose Template

Save as `docker-compose.yml`:

```yaml
version: '3.8'
services:
  geyser:
    build: .
    container_name: geyser-server
    ports:
      - "19132:19132/udp"
    volumes:
      - geyser-data:/geyser/data
      - geyser-config:/geyser/config
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

Run with: `docker-compose up -d`

## Performance Tuning

### Increase Memory
```bash
--memory=4g                                    # 4GB RAM
-e JVM_OPTS="-Xms3g -Xmx6g"                  # Min 3GB, Max 6GB
```

### Limit CPU
```bash
--cpus="2"                                     # Use max 2 CPUs
```

### Simulation Distance
```yaml
# In geyser-config.yml
simulation-distance: 8    # Default 10, lower = less lag
```

## Useful Debugging

### Check if Geyser started
```bash
docker logs geyser-server | grep "Started Geyser"
```

### Check plugin loading
```bash
docker logs geyser-server | grep -i plugin
```

### Test Java server connectivity
```bash
docker exec geyser-server nc -zv java-server-ip 25565
```

### Inspect container details
```bash
docker inspect geyser-server
```

### Resource usage
```bash
docker stats geyser-server
```

## Image Information

- **Size**: ~610 MB
- **Base**: Eclipse Temurin 21 JDK Alpine
- **Java Version**: OpenJDK 21
- **Geyser Version**: Latest standalone
- **Default Port**: UDP 19132
- **Default Memory**: 1GB min, 2GB max (configurable)

## Links

- [Geyser Docs](https://geysermc.org/wiki/geyser/)
- [MCXboxBroadcast](https://github.com/MCXboxBroadcast/Broadcaster)
- [Docker Docs](https://docs.docker.com/)
- [Eclipse Temurin](https://adoptopenjdk.net/)
