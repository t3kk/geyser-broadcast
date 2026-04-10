# CI/CD Automated Build System - Complete Implementation

## Overview

This project now includes a complete automated CI/CD pipeline that:
- Monitors for new releases of Eclipse Temurin LTS, GeyserMC, and MCXboxBroadcast
- Automatically rebuilds the Docker image when dependencies update
- Publishes pre-built images to GitHub Container Registry (GHCR)
- Runs health checks to verify image stability

## How It Works

The workflow uses intelligent version detection:

1. **Version Detection Step**
   - **Temurin**: Uses stable LTS 21 (no polling needed)
   - **Geyser**: Extracts actual version from download.geysermc.org API redirect
     - Sends HEAD request to `/versions/latest/builds/latest/` endpoint
     - Parses the Location header to get actual version (e.g., 2.9.5)
     - Falls back to "latest" if parsing fails
   - **MCXboxBroadcast**: Queries GitHub API for releases

2. **Build Comparison**
   - Compares detected actual versions against `.build.env`
   - Detects when Geyser releases a new version (e.g., 2.9.4 → 2.9.5)
   - Only builds if: versions changed OR manual trigger OR Dockerfile changed
   - Prevents unnecessary builds when nothing has updated

3. **Build & Test**
   - Downloads latest versions from their respective sources
   - Builds optimized Docker image with detected versions
   - Runs health checks to verify functionality
   - Pushes to GHCR with semantic tags

4. **Auto-Update**
   - Commits updated `.build.env` with actual detected versions (e.g., "GEYSER_VERSION=2.9.5")
   - Image labels store version metadata
   - Git history tracks all version changes

### Build Triggers
Builds are automatically triggered by:
1. **Weekly Schedule** - Every Sunday at 00:00 UTC
2. **Manual Dispatch** - Via GitHub Actions UI with optional "Force Build" flag
3. **Dockerfile Changes** - Any push to main branch with Dockerfile modifications

### Image Publishing
- **Registry**: GitHub Container Registry (GHCR)
- **Tags**: `latest`, `stable`, Git commit SHA, branch names
- **Availability**: Public access (no authentication required for pull)

## File Structure

```
geyser-broadcast/
├── Dockerfile                    # Main container definition
├── .github/
│   └── workflows/
│       └── build.yml            # GitHub Actions CI/CD workflow
├── .build.env                   # Version tracking file
├── README.md                    # Main documentation with quick start
├── REGISTRY_SETUP.md            # How to use pre-built images
├── SETUP_GUIDE.md               # Step-by-step first-run guide
├── QUICK_REFERENCE.md           # Common commands and troubleshooting
├── IMPLEMENTATION_SUMMARY.md    # Technical architecture
├── geyser-config-example.yml    # Example Geyser configuration
└── server-properties-example    # Example Java Edition server properties
```

## Key Changes Made

### 1. Dockerfile Enhancements

**Build Arguments for Version Pinning:**
```dockerfile
ARG TEMURIN_VERSION=21-jdk-alpine
ARG GEYSER_DOWNLOAD_URL=https://download.geysermc.org/v2/projects/geyser/versions/latest/builds/latest/downloads/standalone
ARG XBOX_BROADCAST_DOWNLOAD_URL=https://github.com/MCXboxBroadcast/Broadcaster/releases/download/134/MCXboxBroadcastExtension.jar
```

**OCI Image Labels:**
Added metadata labels to track versions in built images:
- `org.opencontainers.image.title`
- `org.opencontainers.image.description`
- `com.github.geyser-broadcast.geyser-download-url`
- `com.github.geyser-broadcast.xbox-broadcast-download-url`

**Health Check:**
Added proper UDP health check that monitors the Geyser port:
```dockerfile
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD /geyser/healthcheck.sh
```

The health check script uses netcat to verify the server is listening on UDP 19132.

### 2. GitHub Actions Workflow (.github/workflows/build.yml)

**Features:**
- Multi-job workflow with intelligent version detection
- Extracts actual Geyser version from download API redirect
- GitHub API queries for MCXboxBroadcast releases
- Semantic versioning for image tags
- Auto-commit of updated `.build.env` file
- Test job that verifies image health
- Matrix strategy for potential multi-architecture builds

**Workflow Jobs:**

1. **check-versions** - Detects latest versions:
   - Temurin: Uses stable 21-jdk-alpine
   - Geyser: Extracts actual version from download.geysermc.org API (e.g., 2.9.5)
   - MCXboxBroadcast: Queries GitHub API for releases
   - Compares with .build.env to determine if build needed

2. **build** - Builds and publishes:
   - Builds Docker image with detected versions
   - Pushes to GHCR with semantic versioning
   - Creates tags: latest, stable, commit-sha, branch names

3. **test** - Validates:
   - Runs container with health checks
   - Verifies Geyser starts correctly
   - Confirms extensions load

## Version Detection Details

### How Each Component is Detected

**Temurin (Java Runtime)**
- Pinned to stable LTS 21-jdk-alpine
- No polling required - stable reference version
- Could be enhanced in future to auto-detect next LTS when released

**GeyserMC (Bedrock Proxy)**
- Uses download.geysermc.org API intelligent endpoint
- Sends HEAD request to: `/v2/projects/geyser/versions/latest/builds/latest/downloads/standalone`
- Geyser's API redirects to actual build: `/v2/projects/geyser/versions/2.9.5/builds/1113/downloads/standalone`
- Workflow extracts version from Location header: **2.9.5**
- This allows detecting when Geyser releases a new version (2.9.4 → 2.9.5)
- More reliable than GitHub polling (Geyser doesn't publish releases on GitHub)

**MCXboxBroadcast (Xbox Live Extension)**
- Queries GitHub API: `/repos/MCXboxBroadcast/Broadcaster/releases/latest`
- Extracts tag_name from JSON response
- Falls back to version 134 if API unavailable
- Robust JSON parsing with jq

### Build Triggering Logic

The workflow **triggers a build** when:
1. ✅ New Geyser version detected (2.9.4 in .build.env → 2.9.5 detected)
2. ✅ New MCXboxBroadcast version detected
3. ✅ Temurin version changes (LTS upgrade)
4. ✅ Manual `force_build=true` flag set
5. ✅ Dockerfile or workflow file modified (push trigger)

The workflow **skips build** when:
- Same versions as .build.env AND
- Scheduled trigger (not manual)
- No Dockerfile changes

### 3. Version Tracking (.build.env)

File format:
```
TEMURIN_VERSION=21-jdk-alpine
TEMURIN_FULL_VERSION=21.0.2
GEYSER_VERSION=2.9.5-b1113
GEYSER_DOWNLOAD_URL=https://download.geysermc.org/v2/projects/geyser/versions/latest/builds/latest/downloads/standalone
XBOX_BROADCAST_VERSION=134
XBOX_BROADCAST_DOWNLOAD_URL=https://github.com/MCXboxBroadcast/Broadcaster/releases/download/134/MCXboxBroadcastExtension.jar
BUILD_DATE=2024-04-10T03:00:00Z
LAST_BUILD_COMMIT=abc123def456
```

This file is automatically updated after each successful build.

### 4. Documentation Updates

**README.md** - Added:
- Build status badge
- Pre-built image usage instructions
- Automated builds section explaining update frequency
- Manual rebuild instructions

**New: REGISTRY_SETUP.md** - Complete guide for:
- GitHub Container Registry setup
- Pulling pre-built images
- Creating personal access tokens
- Making repository public
- Viewing build history

## How to Use

### Option 1: Use Pre-Built Images (Recommended)

No build time required:
```bash
docker pull ghcr.io/USERNAME/geyser-broadcast:latest
docker run -d \
  -p 19132:19132/udp \
  -v geyser-data:/geyser/data \
  -v geyser-config:/geyser/config \
  ghcr.io/USERNAME/geyser-broadcast:latest
```

### Option 2: Manual Build

```bash
docker build -t geyser-mc:latest .
docker run -d \
  -p 19132:19132/udp \
  -v geyser-data:/geyser/data \
  -v geyser-config:/geyser/config \
  geyser-mc:latest
```

### Option 3: Force Rebuild via Actions

1. Go to GitHub Actions tab
2. Select "Build and Push Docker Image"
3. Click "Run workflow"
4. Check "Force build" option
5. Click "Run workflow"

## Deployment Recommendations

### For Servers That Can't Build Images

This project is purpose-built for this use case:

1. **Host A** (build machine): Has GitHub Actions runners
2. **Host B** (server machine): Cannot build images

**Setup:**
1. Push this repository to GitHub
2. Ensure repository is public or set up GHCR access token
3. On server machine, use: `docker pull ghcr.io/USERNAME/geyser-broadcast:latest`
4. Image automatically updates weekly with latest versions
5. To update: pull fresh image and restart container

### For Development/Testing

Use local builds:
```bash
# With specific versions
docker build -t geyser-dev:test \
  --build-arg TEMURIN_VERSION=21-jdk-alpine \
  --build-arg GEYSER_VERSION=2.9.5 .

# Or use latest (default)
docker build -t geyser-dev:latest .
```

## Monitoring Builds

### Check Build Status
1. Go to repository → Actions tab
2. Select "Build and Push Docker Image"
3. View build history with timestamps and status

### View Build Logs
Click on any build run to see:
- Version detection results
- Build output
- Push to GHCR results
- Health check test results

### Image Metadata
View what versions are in a built image:
```bash
docker inspect ghcr.io/USERNAME/geyser-broadcast:latest | grep -A 20 "Labels"
```

Or pull and inspect locally:
```bash
docker pull ghcr.io/USERNAME/geyser-broadcast:latest
docker image inspect ghcr.io/USERNAME/geyser-broadcast:latest | jq '.[] | .Config.Labels'
```

## Resource Usage

**Free Tier GitHub Actions:**
- Public repositories: 2000+ free minutes/month
- Private repositories: 3000 free minutes/month
- Weekly builds (~5-10 min): Uses 40-80 min/month ✅ Well within limits

**Image Size:**
- Current: ~692MB total
- Includes: Java 21 LTS + Geyser + MCXboxBroadcast

**Registry Storage:**
- GHCR: Free for public repositories
- First 500MB free for private repositories

## Architecture Decisions

### Why Weekly Schedule?
- Daily builds would use 240+ minutes/month (risky for free tier)
- Weekly uses 40-80 minutes/month (safe margin)
- Weekly is often enough for server stability (no daily release cadence)

### Why GHCR?
- Free for public repositories
- Integrated with GitHub (no separate account needed)
- Good API for version detection
- Works well with GitHub Actions

### Why Pre-Built Images?
- Saves 5-10 minutes per deployment
- Consistent versions across deployments
- No build system required on deployment host
- Smaller attack surface (no build tools needed)

### Why Docker Build Args?
- Same Dockerfile works with any version combination
- Easy to test with different versions
- CI/CD can rebuild with new versions without modifying Dockerfile
- Supports manual overrides

## Future Enhancements

### Possible Additions
1. **Multi-Architecture**: Add arm64 builds for Raspberry Pi
2. **Docker Hub**: Push to Docker Hub in addition to GHCR
3. **Slack Notifications**: Alert on build failures
4. **Version Pinning**: Option to lock to specific versions
5. **Release Notes**: Generate changelog from release notes
6. **Security Scanning**: Scan images for vulnerabilities

### For Discussion
- Should builds be daily instead of weekly?
- Would you like both `latest` and `stable` channels?
- Any specific versions you want locked to?
- Need multi-architecture support (arm64, etc.)?

## Troubleshooting

### Build Fails with "Can't download Geyser"
- Check network access to download.geysermc.org
- Verify GitHub Actions has outbound network access
- Check workflow logs for specific error

### Image won't push to GHCR
- Verify `GITHUB_TOKEN` has `packages:write` scope
- Check repository settings → Packages
- Verify repository isn't set to private without auth

### Health check fails
- Container may still be starting (has 60s grace period)
- Verify port 19132 is not in use on host
- Check server logs: `docker logs <container-name>`

### Can't pull image
- If private repo: Create PAT with packages:read scope
- If public: Should work without authentication
- Verify image name matches: `ghcr.io/USERNAME/geyser-broadcast:tag`

## Next Steps

1. **Push to GitHub**: Commit and push this repository
2. **Verify Workflow**: Check Actions tab to see if workflow runs
3. **Test Pull**: Try pulling the built image from GHCR
4. **Setup Auto-Updates**: Configure on deployment server to pull weekly
5. **Monitor First Build**: Check logs to ensure smooth operation

## Support

For issues with:
- **Geyser**: https://geysermc.org/wiki/
- **MCXboxBroadcast**: https://github.com/MCXboxBroadcast/Broadcaster
- **Docker**: https://docs.docker.com/
- **GitHub Actions**: https://docs.github.com/en/actions

See QUICK_REFERENCE.md for common troubleshooting.
