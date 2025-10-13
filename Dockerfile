ARG BASE_IMAGE

# Shared stage: Download and verify Zig from community mirrors
FROM alpine:3 AS downloader

ARG ZIG_VERSION

# Install tools needed to download and verify Zig
RUN apk add --no-cache curl minisign xz

# Zig Software Foundation's minisign public key
ENV ZIG_PUBKEY=RWSGOq2NVecA2UPNdBUZykf1CCb147pkmdtYxgb3Ti+JO/wCYvhbAb/U

RUN set -eux; \
    ARCH="$(uname -m)"; \
    case "${ARCH}" in \
        x86_64) ZIG_ARCH='x86_64' ;; \
        aarch64) ZIG_ARCH='aarch64' ;; \
        armv7l) ZIG_ARCH='arm' ;; \
        *) echo "Unsupported architecture: ${ARCH}" && exit 1 ;; \
    esac; \
    ZIG_TARBALL="zig-${ZIG_ARCH}-linux-${ZIG_VERSION}.tar.xz"; \
    \
    # Fetch community mirror list following Zig best practices \
    # https://ziglang.org/download/community-mirrors/ \
    echo "Fetching community mirror list..."; \
    curl -fSL "https://ziglang.org/download/community-mirrors.txt" -o /tmp/mirrors.txt || { \
        echo "Failed to fetch mirror list, falling back to ziglang.org"; \
        echo "https://ziglang.org/download/${ZIG_VERSION}" > /tmp/mirrors.txt; \
    }; \
    \
    # Shuffle mirrors to distribute load and improve reliability \
    MIRRORS=$(shuf /tmp/mirrors.txt | sed "s|$|/${ZIG_VERSION}|"); \
    \
    # Try mirrors in random order until one succeeds with valid signature \
    SUCCESS=0; \
    for MIRROR in ${MIRRORS}; do \
        echo "Trying mirror: ${MIRROR}"; \
        if curl -fSL "${MIRROR}/${ZIG_TARBALL}?source=dockerfile" -o "/tmp/${ZIG_TARBALL}" && \
           curl -fSL "${MIRROR}/${ZIG_TARBALL}.minisig?source=dockerfile" -o "/tmp/${ZIG_TARBALL}.minisig"; then \
            echo "Downloaded from ${MIRROR}, verifying signature..."; \
            if minisign -V -P "${ZIG_PUBKEY}" -x "/tmp/${ZIG_TARBALL}.minisig" -m "/tmp/${ZIG_TARBALL}"; then \
                echo "Successfully verified signature from ${MIRROR}"; \
                SUCCESS=1; \
                break; \
            else \
                echo "Signature verification failed for ${MIRROR}, trying next mirror..."; \
            fi; \
        else \
            echo "Failed to download from ${MIRROR}, trying next..."; \
        fi; \
    done; \
    \
    # As a final fallback, try the official ziglang.org \
    if [ "${SUCCESS}" != "1" ]; then \
        echo "All mirrors failed. Attempting official ziglang.org as final fallback..."; \
        OFFICIAL_URL="https://ziglang.org/download/${ZIG_VERSION}"; \
        if curl -fSL "${OFFICIAL_URL}/${ZIG_TARBALL}?source=dockerfile" -o "/tmp/${ZIG_TARBALL}" && \
           curl -fSL "${OFFICIAL_URL}/${ZIG_TARBALL}.minisig?source=dockerfile" -o "/tmp/${ZIG_TARBALL}.minisig"; then \
            echo "Downloaded from official source, verifying signature..."; \
            if minisign -V -P "${ZIG_PUBKEY}" -x "/tmp/${ZIG_TARBALL}.minisig" -m "/tmp/${ZIG_TARBALL}"; then \
                echo "Successfully verified signature from official source"; \
                SUCCESS=1; \
            else \
                echo "Signature verification failed for official source"; \
            fi; \
        else \
            echo "Failed to download from official source"; \
        fi; \
    fi; \
    \
    if [ "${SUCCESS}" != "1" ]; then \
        echo "ERROR: Failed to download and verify Zig from any source"; \
        exit 1; \
    fi; \
    \
    # Extract and install \
    mkdir -p /usr/local/zig; \
    tar -xJf "/tmp/${ZIG_TARBALL}" -C /usr/local/zig --strip-components=1; \
    \
    # Verify installation \
    /usr/local/zig/zig version; \
    \
    # Cleanup \
    rm -rf /tmp/*

# Final stage - parameterized by base image
FROM ${BASE_IMAGE} AS final

LABEL org.opencontainers.image.source="https://github.com/mattrobenolt/zig-docker"
COPY --from=downloader /usr/local/zig /usr/local/zig
ENV PATH="/usr/local/zig:${PATH}"
CMD ["zig", "version"]
