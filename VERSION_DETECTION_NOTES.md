# Version Detection - Technical Notes

## Problem Identified

Initially, the workflow tried to use `geyser-version=latest` for version tracking, which would prevent detection of new Geyser releases because:

- Workflow would always detect: `geyser-version=latest`
- `.build.env` would also have: `GEYSER_VERSION=latest`
- Version comparison: `"latest" == "latest"` → No build triggered
- **Result**: Even if Geyser released v2.9.6, the workflow wouldn't rebuild

## Solution Implemented

The workflow now **extracts the actual version number** from GeyserMC's download API.

### How It Works

1. **HEAD Request to Download API**
   ```
   curl -sI https://download.geysermc.org/v2/projects/geyser/versions/latest/builds/latest/downloads/standalone
   ```

2. **Parse HTTP Redirect Response**
   - GeyserMC returns HTTP 302 with Location header
   - Example redirect: `/v2/projects/geyser/versions/2.9.5/builds/1113/downloads/standalone`

3. **Extract Version Number**
   ```bash
   GEYSER_VERSION=$(curl -sI ... | grep -i "location:" | grep -o '/versions/[^/]*' | cut -d'/' -f3)
   # Result: GEYSER_VERSION=2.9.5
   ```

4. **Store Actual Version**
   - `.build.env` now contains: `GEYSER_VERSION=2.9.5` (not "latest")
   - Next build detects: `GEYSER_VERSION=2.9.6`
   - Comparison: `"2.9.6" != "2.9.5"` → Build triggered! ✅

## Release Detection Workflow

```
Weekly Scheduled Build
    ↓
1. Detect Geyser version from API → 2.9.5
2. Detect MCXboxBroadcast from GitHub → 134
3. Detect Temurin version → 21-jdk-alpine
    ↓
4. Compare with .build.env
   Geyser: 2.9.5 vs 2.9.5 (same)
   MCXboxBroadcast: 134 vs 134 (same)
   Temurin: 21-jdk-alpine vs 21-jdk-alpine (same)
    ↓
5. Build Decision
   No changes detected → Skip build
   (saves resources, still respects manual force)

When New Release Comes:
    ↓
1. Detect Geyser version from API → 2.9.6 (NEW!)
2-4. Compare with .build.env
   Geyser: 2.9.6 vs 2.9.5 (different!)
    ↓
5. Build Decision
   Version changed → Trigger build!
   Download Geyser 2.9.6
   Build new image
   Push to GHCR
   Update .build.env and commit
```

## Version Sources

### Temurin (Java Runtime)
- **Source**: Hard-coded as `21-jdk-alpine` (stable LTS)
- **Reasoning**: Temurin LTS versions are predictable and stable
- **Enhancement Potential**: Could poll GitHub for next LTS release

### GeyserMC (Bedrock Proxy)
- **Source**: Download API redirect header parsing
- **URL**: `/v2/projects/geyser/versions/latest/builds/latest/downloads/standalone`
- **Method**: Extract version from Location header (e.g., `2.9.5`)
- **Reliability**: More reliable than GitHub API (GeyserMC doesn't publish GitHub releases)
- **Fallback**: Uses "latest" if parsing fails

### MCXboxBroadcast (Extension)
- **Source**: GitHub API releases endpoint
- **URL**: `/repos/MCXboxBroadcast/Broadcaster/releases/latest`
- **Method**: Extract `tag_name` from JSON response using jq
- **Reliability**: Direct GitHub releases (works when API available)
- **Fallback**: Uses version `134` if API unavailable

## Testing & Verification

All version detection methods have been tested:

✅ Geyser version extraction: Returns 2.9.5
✅ Version change detection: Triggers build on 2.9.4 → 2.9.5
✅ Version consistency: Multiple calls return same version
✅ MCXboxBroadcast detection: Returns 134
✅ Fallback handling: Uses defaults if API fails
✅ Build comparison: Correctly compares versions

## Edge Cases Handled

1. **API Timeout**: Fallback to previous version (no build)
2. **Failed Parsing**: Fallback to "latest" (always builds)
3. **Network Error**: Curl failures caught with error redirection
4. **Null JSON Response**: Checked with explicit null handling
5. **Empty Strings**: Checked with string length tests

## Production Impact

- ✅ No impact on Docker builds (same URLs used)
- ✅ More reliable than GitHub polling
- ✅ Accurately detects new Geyser releases
- ✅ Respects free tier GitHub Actions limits
- ✅ Auto-commits version changes to repo

## Future Improvements

1. **Temurin LTS Detection**: Poll GitHub for next LTS when available
2. **Version History**: Track version changes in GitHub releases
3. **Webhook Notifications**: Alert on new releases instead of polling
4. **Multi-Architecture**: Build for arm64, arm32, etc.
5. **Docker Hub**: Push to Docker Hub in addition to GHCR

---

**Last Updated**: April 2026
**Status**: Production Ready ✅
