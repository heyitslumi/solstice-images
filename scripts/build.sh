#!/usr/bin/env bash
# Build a Solstice Incus image with distrobuilder.
# Only amd64 and arm64 are supported — other architectures are
# intentionally not built (no other nodes need them).
# Usage: ./scripts/build.sh <debian|ubuntu> <release> [amd64|arm64] [--container]
set -euo pipefail

DISTRO="${1:?usage: build.sh <debian|ubuntu> <release> [amd64|arm64] [--container]}"
RELEASE="${2:?missing release}"
ARCH="${3:-amd64}"
MODE="${4:-vm}"

case "$ARCH" in
  amd64|arm64) ;;
  *) echo "unsupported architecture: $ARCH (only amd64 and arm64)" >&2; exit 1 ;;
esac

YAML="images/${DISTRO}.yaml"
[ -f "$YAML" ] || { echo "no such definition: $YAML" >&2; exit 1; }

ARGS=(build-incus "$YAML" -o "image.release=${RELEASE}" -o "image.architecture=${ARCH}")
if [ "$MODE" = "vm" ]; then
  ARGS+=(--vm)
fi

echo "+ distrobuilder ${ARGS[*]}"
sudo distrobuilder "${ARGS[@]}"
echo "done: incus.tar.xz + rootfs.* in $(pwd)"
