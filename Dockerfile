FROM eclipse-temurin:${TEMURIN_VERSION:-21-jdk-alpine}

# Install curl, bash, and netcat for startup and health checks
RUN apk add --no-cache curl bash netcat-openbsd

# Create app directory
WORKDIR /geyser

# Create necessary directories
RUN mkdir -p /geyser/data /geyser/config /geyser/extensions /geyser/plugins /geyser/logs

# Download Geyser standalone
ARG GEYSER_DOWNLOAD_URL=https://download.geysermc.org/v2/projects/geyser/versions/latest/builds/latest/downloads/standalone
RUN echo "Downloading Geyser..." && \
    curl -L -o /geyser/geyser.jar ${GEYSER_DOWNLOAD_URL} && \
    ls -lh /geyser/geyser.jar

# Download MCXboxBroadcast extension
ARG XBOX_BROADCAST_DOWNLOAD_URL=https://github.com/MCXboxBroadcast/Broadcaster/releases/download/134/MCXboxBroadcastExtension.jar
RUN echo "Downloading MCXboxBroadcast extension..." && \
    curl -L -o /geyser/extensions/MCXboxBroadcastExtension.jar ${XBOX_BROADCAST_DOWNLOAD_URL} && \
    ls -lh /geyser/extensions/MCXboxBroadcastExtension.jar

# Create a startup wrapper script
RUN cat > /geyser/start.sh << 'EOF'
#!/bin/bash
set -e

echo "Starting Geyser server with MCXboxBroadcast extension..."
exec java -Xms1024M -Xmx2048M -jar /geyser/geyser.jar
EOF

RUN chmod +x /geyser/start.sh

# Create health check script
RUN cat > /geyser/healthcheck.sh << 'EOF'
#!/bin/bash
# Check if Geyser is responding on the Bedrock port
nc -u -z -w1 127.0.0.1 19132 2>/dev/null && echo "Geyser is healthy" || exit 1
EOF

RUN chmod +x /geyser/healthcheck.sh

# Add OCI labels
LABEL org.opencontainers.image.title="Geyser Docker with MCXboxBroadcast"
LABEL org.opencontainers.image.description="Geyser server with MCXboxBroadcast extension for Xbox Live integration"
LABEL org.opencontainers.image.source="https://github.com/GeyserMC/Geyser"
LABEL com.github.geyser-broadcast.geyser-download-url="${GEYSER_DOWNLOAD_URL}"
LABEL com.github.geyser-broadcast.xbox-broadcast-download-url="${XBOX_BROADCAST_DOWNLOAD_URL}"

# Expose Bedrock port
EXPOSE 19132/udp

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD /geyser/healthcheck.sh

# Use the startup script
ENTRYPOINT ["/geyser/start.sh"]
