# Moved to baskingspot/zig-docker

This repository is archived. The images build and publish from [baskingspot/zig-docker](https://github.com/baskingspot/zig-docker) as `ghcr.io/baskingspot/zig`.

The tags already published at `ghcr.io/mattrobenolt/zig` stay frozen at the last build from `main`, commit `9cb896b`. They get no new Zig releases.

## Migrate

Replace `ghcr.io/mattrobenolt/zig` with `ghcr.io/baskingspot/zig` in your `FROM` lines. The tag scheme is unchanged: `:<version>`, `:<version>-chainguard`, and `:<version>-alpine`. The new images cover Zig 0.15.2, 0.16.0, and 0.17.0 on `linux/amd64` and `linux/arm64`.

```dockerfile
FROM ghcr.io/baskingspot/zig:0.17.0 AS builder
```
