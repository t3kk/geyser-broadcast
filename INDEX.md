# Documentation Index

Quick navigation for all documentation in this project.

## 📖 Getting Started

Start here if you're new to this project:

1. **[README.md](./README.md)** - Main documentation
   - Project overview
   - Quick start (pre-built vs local build)
   - Configuration options
   - Troubleshooting

2. **[SETUP_GUIDE.md](./SETUP_GUIDE.md)** - Step-by-step walkthrough
   - First-time setup instructions
   - MCXboxBroadcast configuration
   - Xbox Live authentication
   - Connecting clients

3. **[VOLUME_SETUP.md](./VOLUME_SETUP.md)** - Volume mounting guide
   - Creating config directory
   - Configuring geyser-config.yml
   - Docker run examples
   - Docker Compose setup
   - Troubleshooting

4. **[QUICK_REFERENCE.md](./QUICK_REFERENCE.md)** - Common commands
   - Docker commands
   - Volume management
   - Troubleshooting quick fixes
   - Performance tuning

## 🚀 Using Pre-Built Images

If using automatic builds from GitHub Container Registry:

1. **[REGISTRY_SETUP.md](./REGISTRY_SETUP.md)** - GHCR setup and usage
   - Container Registry setup
   - Authentication
   - Pulling pre-built images
   - Making repository public
   - Available image tags

2. **[CI_CD_SUMMARY.md](./CI_CD_SUMMARY.md)** - CI/CD automation details
   - How automated builds work
   - Version detection process
   - Build triggers and schedules
   - Resource usage

## 📋 For Deployment

Setting up on deployment servers:

1. **[DEPLOYMENT_CHECKLIST.md](./DEPLOYMENT_CHECKLIST.md)** - Step-by-step deployment
   - Repository setup verification
   - GitHub Actions configuration
   - First build verification
   - GHCR registry setup
   - Image pull testing
   - Scheduled build verification
   - Deployment server setup
   - Troubleshooting reference

## 🏗️ Technical Documentation

For developers and maintainers:

1. **[IMPLEMENTATION_SUMMARY.md](./IMPLEMENTATION_SUMMARY.md)** - Technical architecture
   - System architecture
   - Component descriptions
   - Build process details
   - Deployment recommendations
   - Security considerations
   - Performance notes

2. **[Dockerfile](./Dockerfile)** - Container definition
   - Base image (Eclipse Temurin 21 LTS)
   - Dependency installation
   - Application setup
   - Health checks
   - Build arguments

3. **[.github/workflows/build.yml](./.github/workflows/build.yml)** - CI/CD pipeline
   - Automated build workflow
   - Version detection jobs
   - Build and push jobs
   - Test and health check jobs
   - Scheduled triggers

## 📁 Configuration Files

Example and reference files:

- **[geyser-config-example.yml](./geyser-config-example.yml)** - Geyser configuration template
- **[server-properties-example](./server-properties-example)** - Java Edition server properties template
- **[.build.env](./.build.env)** - Version tracking for CI/CD
- **[.gitignore](./.gitignore)** - Git ignore patterns for Docker artifacts

## 🔍 Quick Navigation by Task

### "I want to..."

**...run this locally**
- See: README.md → Quick Start → Option 2: Build Locally

**...use a pre-built image from GHCR**
- See: README.md → Quick Start → Option 1: Use Pre-Built Image
- Then: REGISTRY_SETUP.md → Using Pre-Built Images

**...set up automated builds**
- See: DEPLOYMENT_CHECKLIST.md (step-by-step)
- Reference: CI_CD_SUMMARY.md (technical details)

**...troubleshoot issues**
- See: QUICK_REFERENCE.md → Troubleshooting
- Or: README.md → Troubleshooting section

**...understand the architecture**
- See: IMPLEMENTATION_SUMMARY.md

**...mount config directory**
- See: VOLUME_SETUP.md (detailed guide)
- Or: README.md → Configuration → Volume Mounts

**...configure MCXboxBroadcast**
- See: SETUP_GUIDE.md → Step 7: MCXboxBroadcast Authentication
- Or: README.md → Configuration → MCXboxBroadcast Configuration

**...contribute or modify**
- See: IMPLEMENTATION_SUMMARY.md → Architecture Decisions
- Reference: Dockerfile for build process

**...deploy to production**
- See: DEPLOYMENT_CHECKLIST.md
- Reference: IMPLEMENTATION_SUMMARY.md → Deployment Recommendations

**...connect Bedrock clients**
- See: SETUP_GUIDE.md → Step 8: Connect Bedrock Clients
- Or: README.md → Exposed Ports section

**...check what's in an image**
- See: IMPLEMENTATION_SUMMARY.md → Architecture
- Or: README.md → Architecture section

## 
**For Geyser questions:**
- Official Wiki: https://geysermc.org/wiki/geyser/
- Configuration Guide: https://geysermc.org/wiki/geyser/Configuration/

**For MCXboxBroadcast questions:**
- GitHub: https://github.com/MCXboxBroadcast/Broadcaster
- Issues: https://github.com/MCXboxBroadcast/Broadcaster/issues

**For Docker questions:**
- Documentation: https://docs.docker.com/
- Getting Started: https://docs.docker.com/get-started/

**For GitHub Actions questions:**
- Documentation: https://docs.github.com/en/actions
- Workflows: https://docs.github.com/en/actions/learn-github-actions

## 📊 File Overview

| File | Purpose | Audience |
|------|---------|----------|
| README.md | Main guide and quick start | Everyone |
| SETUP_GUIDE.md | Step-by-step setup | New users |
| VOLUME_SETUP.md | Volume mounting guide | Docker users |
| QUICK_REFERENCE.md | Common commands | Active users |
| REGISTRY_SETUP.md | GHCR usage guide | Users of pre-built images |
| CI_CD_SUMMARY.md | Automation details | Admins/DevOps |
| DEPLOYMENT_CHECKLIST.md | Deployment verification | DevOps/Sysadmins |
| IMPLEMENTATION_SUMMARY.md | Technical architecture | Developers |
| Dockerfile | Container definition | Developers/DevOps |
| .github/workflows/build.yml | CI/CD automation | Developers/DevOps |
| INDEX.md (this file) | Documentation guide | Everyone |

## 🎯 Recommended Reading Order

**First Time?**
1. README.md (Overview)
2. SETUP_GUIDE.md (Setup)
3. QUICK_REFERENCE.md (Commands)

**Setting Up Automated Builds?**
1. CI_CD_SUMMARY.md (What it does)
2. DEPLOYMENT_CHECKLIST.md (How to deploy)
3. REGISTRY_SETUP.md (Using the images)

**Developing/Maintaining?**
1. IMPLEMENTATION_SUMMARY.md (Architecture)
2. Dockerfile (Build process)
3. .github/workflows/build.yml (CI/CD)

**Troubleshooting?**
1. QUICK_REFERENCE.md (Quick fixes)
2. README.md → Troubleshooting (Common issues)
3. IMPLEMENTATION_SUMMARY.md (Technical details)

---

**Last Updated**: April 2024
**Version**: Complete with CI/CD automation
