#!/usr/bin/env bash
# Add a built image to a simplestreams tree and serve it.
# Usage:
#   STREAM_DIR=/var/www/solstice-images ./scripts/publish.sh \
#     ./incus.tar.xz ./rootfs.qcow2 solstice/debian/13/cloud
#
# Then serve $STREAM_DIR over https and add the remote on each node:
#   incus remote add solstice https://<image-server>/ --protocol simplestreams
#   incus launch solstice:solstice/debian/13/cloud my-vm --vm
set -euo pipefail

META="${1:?usage: publish.sh <incus.tar.xz> <rootfs.qcow2|squashfs> <alias>}"
ROOTFS="${2:?missing rootfs}"
ALIAS="${3:?missing alias}"
STREAM_DIR="${STREAM_DIR:-./stream}"

mkdir -p "$STREAM_DIR"
cd "$STREAM_DIR"

echo "+ incus-simplestreams add $META $ROOTFS --alias $ALIAS"
incus-simplestreams add "$META" "$ROOTFS" --alias "$ALIAS"

echo "+ incus-simplestreams list"
incus-simplestreams list

cat <<EOF

Stream tree ready in $STREAM_DIR
(subpath /images/ on the web server, e.g. https://<host>/images/)

On each node:
  incus remote add solstice https://<host>/images/ --protocol simplestreams
  incus image info solstice:$ALIAS
EOF
