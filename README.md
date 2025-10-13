# Zig Docker Images

Unofficial Docker images for the [Zig programming language](https://ziglang.org/) compiler.

Published to GitHub Container Registry at `ghcr.io/mattrobenolt/zig`.

## Images

- **Debian** (glibc): `ghcr.io/mattrobenolt/zig:0.15.1` or `ghcr.io/mattrobenolt/zig:0.15.1-debian`
- **Alpine** (musl): `ghcr.io/mattrobenolt/zig:0.15.1-alpine`

Both support `linux/amd64` and `linux/arm64`.

## Usage

```dockerfile
FROM ghcr.io/mattrobenolt/zig:0.15.1 AS builder
WORKDIR /app
COPY . .
RUN zig build -Doptimize=ReleaseFast

FROM debian:bookworm-slim
COPY --from=builder /app/zig-out/bin/myapp /usr/local/bin/myapp
ENTRYPOINT ["myapp"]
```

## Security

Images are built following [Zig's documented best practices](https://ziglang.org/download/community-mirrors/). All downloads are cryptographically verified using minisign against the Zig Software Foundation's public key.

## License

MIT License. See [LICENSE](LICENSE).