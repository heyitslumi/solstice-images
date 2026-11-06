#!/usr/bin/env bash
# Build a Solstice Incus image with distrobuilder.
# Usage: ./scripts/build.sh <debian|ubuntu> <release> [--container]
set -euo pipefail

DISTRO="${1:?usage: build.sh <debian|ubuntu> <release> [--container]}"
RELEASE="${2:?missing release}"
MODE="${3:-vm}"

YAML="images/${DISTRO}.yaml"
[ -f "$YAML" ] || { echo "no such definition: $YAML" >&2; exit 1; }

ARGS=(build-incus "$YAML" -o "image.release=${RELEASE}" -o image.architecture=amd64)
if [ "$MODE" = "vm" ]; then
  ARGS+=(--vm)
fi

echo "+ distrobuilder ${ARGS[*]}"
sudo distrobuilder "${ARGS[@]}"
echo "done: incus.tar.xz + rootfs.* in $(pwd)"
