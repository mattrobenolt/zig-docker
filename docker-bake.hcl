variable "ZIG_VERSION" {}

variable "REGISTRY" {
  default = "ghcr.io/mattrobenolt/zig"
}

group "default" {
  targets = ["debian", "alpine"]
}

target "debian" {
  context    = "."
  dockerfile = "Dockerfile"
  target     = "final"
  tags = [
    "${REGISTRY}:${ZIG_VERSION}",
    "${REGISTRY}:${ZIG_VERSION}-debian"
  ]
  args = {
    BASE_IMAGE  = "debian:bookworm-slim"
    ZIG_VERSION = "${ZIG_VERSION}"
  }
}

target "alpine" {
  context    = "."
  dockerfile = "Dockerfile"
  target     = "final"
  tags = [
    "${REGISTRY}:${ZIG_VERSION}-alpine"
  ]
  args = {
    BASE_IMAGE  = "alpine:3"
    ZIG_VERSION = "${ZIG_VERSION}"
  }
}
