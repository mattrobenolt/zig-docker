variable "ZIG_VERSION" {}

variable "REGISTRY" {
  default = "ghcr.io/mattrobenolt/zig"
}

group "default" {
  targets = ["chainguard", "alpine"]
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

target "chainguard" {
  context    = "."
  dockerfile = "Dockerfile"
  target     = "final"
  tags = [
    "${REGISTRY}:${ZIG_VERSION}",
    "${REGISTRY}:${ZIG_VERSION}-chainguard"
  ]
  args = {
    BASE_IMAGE  = "cgr.dev/chainguard/static:latest"
    ZIG_VERSION = "${ZIG_VERSION}"
  }
}
