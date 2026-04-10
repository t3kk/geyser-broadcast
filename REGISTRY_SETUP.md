# GitHub Container Registry Setup

This project uses GitHub Container Registry (GHCR) for automated Docker image builds.

## Prerequisites

- GitHub repository with Actions enabled
- Container registry will use `ghcr.io` (GitHub Container Registry)
- No additional configuration needed - uses `GITHUB_TOKEN` from Actions

## Automatic Setup

The GitHub Actions workflow automatically:
1. Builds a Docker image on:
   - Weekly schedule (every Sunday at 00:00 UTC)
   - Manual trigger via "Actions" tab
   - Any push to `main` branch that modifies Dockerfile
2. Checks for latest versions of Temurin, Geyser, and MCXboxBroadcast
3. Pushes to `ghcr.io/{owner}/geyser-broadcast` with tags:
   - `latest` (always available)
   - `stable` (for main branch builds)
   - Git commit SHA
   - Git branch names

## Using Pre-Built Images

Instead of building locally, pull the pre-built image:

```bash
# Authenticate with GHCR
echo $GITHUB_TOKEN | docker login ghcr.io -u USERNAME --password-stdin

# Pull image
docker pull ghcr.io/USERNAME/geyser-broadcast:latest

# Run pre-built image (no build needed!)
docker run -d \
  -p 19132:19132/udp \
  -v geyser-data:/geyser/data \
  -v geyser-config:/geyser/config \
  ghcr.io/USERNAME/geyser-broadcast:latest
```

Replace:
- `USERNAME` with your GitHub username
- `GITHUB_TOKEN` with a Personal Access Token (fine-grained with `packages:read` scope)

## Personal Access Token for Pulling

1. Go to https://github.com/settings/tokens?type=beta
2. Click "Generate new token"
3. Name: "GHCR Pull"
4. Expiration: 90 days (recommended)
5. Scopes: Select "Packages: Read"
6. Generate and save the token
7. Use to authenticate: `docker login ghcr.io -u USERNAME -p TOKEN`

## Making Repository Public (Optional)

To make the image publicly downloadable without authentication:

1. Go to repository Settings → Package settings
2. Find the package "geyser-broadcast"
3. Click to manage package visibility
4. Change to "Public"

Then others can pull without authentication:
```bash
docker pull ghcr.io/USERNAME/geyser-broadcast:latest
```

## Image Tags

Available tags from automated builds:

- `latest` - Most recent build from main branch
- `stable` - Latest stable release
- `{sha}` - Specific commit SHA
- `main` - Latest from main branch
- Version tags if you implement semantic versioning

View all tags:
```bash
docker images | grep ghcr.io
# Or via GitHub UI: https://github.com/USERNAME/geyser-broadcast/pkgs/container/geyser-broadcast
```

## Workflow Details

See `.github/workflows/build.yml` for:
- Build schedule configuration
- Version detection logic
- Tag strategy
- Conditional build logic

## Manual Rebuild

To force a rebuild even if versions haven't changed:

1. Go to repository
2. Actions tab → "Build and Push Docker Image"
3. "Run workflow" → Check "Force build" → Run workflow

## Build Status

View build history and logs:
1. Go to repository
2. Actions tab → "Build and Push Docker Image"
3. See all recent builds with status

## Troubleshooting

**Image won't push**: Check that `GITHUB_TOKEN` has `packages:write` scope (automatic in Actions)

**Can't pull image**: Verify:
- Repository is public OR you have authentication token
- Tag name is correct
- Repository exists and has completed at least one build

**Build stuck**: Check workflow logs in Actions tab for errors

## Next Steps

After setting up registry:
1. Users can pull pre-built images: `docker pull ghcr.io/USERNAME/geyser-broadcast:latest`
2. No need to build locally (saves time!)
3. Always get latest versions automatically
4. Updates happen weekly on schedule
