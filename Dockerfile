#############################
# Stage 1: Builder
#############################
FROM python:3.12-slim-bookworm AS builder

# Install build dependencies
RUN apt-get update && apt-get install -y curl && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy requirements and install Python dependencies using a cache mount.
COPY requirements.txt /
RUN --mount=type=cache,target=/root/.cache/pip \
    python3 -m pip install -r requirements.txt && rm requirements.txt

# Add application files (using your ADD patterns)
ADD /ex_app/cs[s] /ex_app/css
ADD /ex_app/im[g] /ex_app/img
ADD /ex_app/j[s] /ex_app/js
ADD /ex_app/l10[n] /ex_app/l10n
ADD /ex_app/li[b] /ex_app/lib

# Copy scripts with the proper permissions.
COPY --chmod=775 healthcheck.sh /
COPY --chmod=775 start.sh /

# Download and install FRP client into /usr/local/bin.
RUN set -ex; \
    ARCH=$(uname -m); \
    if [ "$ARCH" = "aarch64" ]; then \
      FRP_URL="https://raw.githubusercontent.com/nextcloud/HaRP/main/exapps_dev/frp_0.61.1_linux_arm64.tar.gz"; \
    else \
      FRP_URL="https://raw.githubusercontent.com/nextcloud/HaRP/main/exapps_dev/frp_0.61.1_linux_amd64.tar.gz"; \
    fi; \
    echo "Downloading FRP client from $FRP_URL"; \
    curl -L "$FRP_URL" -o /tmp/frp.tar.gz; \
    tar -C /tmp -xzf /tmp/frp.tar.gz; \
    mv /tmp/frp_0.61.1_linux_* /tmp/frp; \
    cp /tmp/frp/frpc /usr/local/bin/frpc; \
    chmod +x /usr/local/bin/frpc; \
    rm -rf /tmp/frp /tmp/frp.tar.gz

#############################
# Stage 2: Final Runtime Image
#############################
FROM python:3.12-slim-bookworm

# Install any runtime apt packages your app needs.
RUN apt-get update && apt-get install -y curl procps && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy installed Python packages and FRP client from the builder.
COPY --from=builder /usr/local/ /usr/local/
# Copy application files and scripts from the builder.
COPY --from=builder /ex_app/ /ex_app/
COPY --from=builder /healthcheck.sh /healthcheck.sh
COPY --from=builder /start.sh /start.sh

# Set working directory and define entrypoint/healthcheck.
WORKDIR /ex_app/lib
ENTRYPOINT ["/start.sh"]
HEALTHCHECK --interval=2s --timeout=2s --retries=300 CMD /healthcheck.sh
