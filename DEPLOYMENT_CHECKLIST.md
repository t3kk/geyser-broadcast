# Deployment Checklist

Use this checklist to ensure your project is properly set up on GitHub with automated CI/CD.

## Repository Setup ✅

- [ ] Repository created on GitHub (public or private)
- [ ] Dockerfile pushed to `main` branch
- [ ] `.github/workflows/build.yml` present in repository
- [ ] `.build.env` file present in root
- [ ] Documentation files pushed (README.md, SETUP_GUIDE.md, etc.)

## GitHub Actions Configuration ✅

- [ ] Go to repository Settings → Actions → General
- [ ] Verify "Actions permissions" is enabled
- [ ] Verify "Workflow permissions" include "Read and write permissions"
- [ ] Check Actions tab to see workflow file listed

## First Build Verification ✅

- [ ] Go to Actions tab in GitHub
- [ ] Select "Build and Push Docker Image"
- [ ] Manually trigger: "Run workflow" → "Run workflow"
- [ ] Wait for build to complete (5-10 minutes)
- [ ] Check logs in workflow run for:
  - ✅ Version detection succeeded
  - ✅ Image built successfully
  - ✅ Image pushed to GHCR
  - ✅ Health check test passed

## GHCR Registry Setup ✅

- [ ] Go to https://github.com/USERNAME/geyser-broadcast/settings/packages
- [ ] Locate container "geyser-broadcast"
- [ ] Change to "Public" if you want unauthenticated pulls
  - Or keep private if you want to restrict access

## Test Image Pull ✅

```bash
# If public repository (no authentication needed):
docker pull ghcr.io/USERNAME/geyser-broadcast:latest

# If private repository (need personal access token):
echo $GITHUB_TOKEN | docker login ghcr.io -u USERNAME --password-stdin
docker pull ghcr.io/USERNAME/geyser-broadcast:latest
```

- [ ] Pull succeeded
- [ ] Image runs: `docker run -d -p 19132:19132/udp ghcr.io/USERNAME/geyser-broadcast:latest`
- [ ] Check logs: `docker logs <container-id>`
- [ ] Verify MCXboxBroadcast loaded: `docker logs <container-id> | grep MCXboxBroadcast`

## Scheduled Builds ✅

- [ ] Confirm workflow is set to run weekly (Sundays at 00:00 UTC)
- [ ] After first Sunday, check Actions tab to verify it ran automatically
- [ ] If it ran, check that new image was built and pushed

## Deployment Server Setup ✅

For servers that can't build images locally:

```bash
# Option 1: One-time pull and run
docker pull ghcr.io/USERNAME/geyser-broadcast:latest
docker run -d \
  --name geyser-server \
  -p 19132:19132/udp \
  -v geyser-data:/geyser/data \
  -v geyser-config:/geyser/config \
  ghcr.io/USERNAME/geyser-broadcast:latest

# Option 2: Weekly auto-update with cron (on deployment server)
# Edit crontab with: crontab -e
# Add line: 0 1 * * 1 docker pull ghcr.io/USERNAME/geyser-broadcast:latest && docker-compose up -d
```

- [ ] Image pulls successfully on deployment server
- [ ] Container starts without errors
- [ ] Port 19132/UDP is accessible
- [ ] Players can connect

## Monitoring Setup (Optional) ✅

- [ ] Set up GitHub Actions notifications in Settings → Notifications
- [ ] Consider Slack/Discord webhook for build failures
- [ ] Monitor container health: `docker inspect <container-id> | grep -A 5 Health`

## Backup & Documentation ✅

- [ ] README updated with your repository URL
- [ ] REGISTRY_SETUP.md printed or saved for reference
- [ ] Build badge shows correct repository URL
- [ ] Documented your GHCR token location for recovery

## Post-Deployment Checklist ✅

### After First Full Week:
- [ ] At least one automatic build completed (next Sunday)
- [ ] New build image is available in GHCR
- [ ] Pull the updated image to verify
- [ ] Check `.build.env` was updated in repository

### Ongoing Maintenance:
- [ ] Weekly monitor workflow runs (Actions tab)
- [ ] Check for build failures in notifications
- [ ] Periodically verify image health: `docker health check <container-id>`
- [ ] Test image pull/run procedure quarterly
- [ ] Monitor image size trends

## Troubleshooting Reference

### Issue: Workflow doesn't appear in Actions tab
- **Solution**: Ensure `.github/workflows/build.yml` is in correct path
- **Solution**: Push to `main` branch (workflow only runs on main)

### Issue: Build fails with "not found" errors
- **Solution**: Check network access - may need to request domain access
- **Solution**: Verify curl/wget can reach download.geysermc.org

### Issue: Can't push to GHCR
- **Solution**: Verify GITHUB_TOKEN has packages:write scope (automatic in Actions)
- **Solution**: If using personal token, ensure it has correct scopes

### Issue: Image won't pull
- **Solution**: If private repo, need authentication token
- **Solution**: Verify image name format: `ghcr.io/USERNAME/REPO:tag`

### Issue: Container starts but health check fails
- **Solution**: Wait 60 seconds (health check grace period)
- **Solution**: Check port 19132/UDP not in use
- **Solution**: Review container logs for errors

## Roll-Back Procedure

If a build causes issues:

```bash
# 1. Get previous working image hash
docker images ghcr.io/USERNAME/geyser-broadcast

# 2. Use specific tag or commit SHA
docker pull ghcr.io/USERNAME/geyser-broadcast:PREVIOUS-SHA

# 3. Or pull from tag (if you set stable tags)
docker pull ghcr.io/USERNAME/geyser-broadcast:stable

# 4. Run previous version
docker run -d -p 19132:19132/udp \
  ghcr.io/USERNAME/geyser-broadcast:PREVIOUS-SHA
```

## Support Resources

- **Project Issues**: See troubleshooting in QUICK_REFERENCE.md
- **GitHub Actions**: https://docs.github.com/en/actions
- **Geyser**: https://geysermc.org/wiki/
- **MCXboxBroadcast**: https://github.com/MCXboxBroadcast/Broadcaster
- **Docker**: https://docs.docker.com/

---

**Last Updated**: April 2024
**Next Review**: After first scheduled build completes
