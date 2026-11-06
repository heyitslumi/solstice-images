# solstice-images

Solstice-branded Incus cloud images, built with
[distrobuilder](https://github.com/lxc/distrobuilder).

The definitions in `images/` are derived from the official Incus
definitions in [lxc/lxc-ci](https://github.com/lxc/lxc-ci/tree/main/images)
(`debian.yaml`, `ubuntu.yaml`), with Solstice branding added on top:

- `/etc/motd` + `/etc/issue.net` — "Welcome to Solstice ..."
- `/etc/cloud/cloud.cfg.d/99-solstice.cfg` — Solstice cloud-init defaults
  (`preserve_hostname: false`, `ssh_pwauth: true`)

Everything else (packages, cloud-init templates, growpart, incus-agent,
network config) comes straight from upstream.

## Images

| File | Releases | Alias pattern (planned) |
| --- | --- | --- |
| `images/debian.yaml` | Debian 11 (Bullseye), 12 (Bookworm), 13 (Trixie) | `solstice/debian/<11\|12\|13>/cloud` |
| `images/ubuntu.yaml` | Ubuntu 20.04 (Focal), 22.04 (Jammy), 24.04 (Noble), 26.04 (Resolute) | `solstice/ubuntu/<20.04\|22.04\|24.04\|26.04>/cloud` |

All releases are built from the same definition per distro —
the release is a build-time option (`-o image.release=...`), so
there is one yaml per distro, not per release.

> Note: Debian Bullseye and Ubuntu Focal support was restored from
> older upstream revisions (lxc-ci dropped bullseye on 2026-09-06
> and focal on 2025-06-28). If an old release stops building
> upstream, check the bullseye/focal-specific blocks in the yamls
> first.

## Architectures

Only **amd64** and **arm64** are built. Other upstream architectures
(armhf, riscv64, ppc64le, s390x, ...) are intentionally skipped — no
nodes need them. `scripts/build.sh` rejects any other architecture.

## Build

Requirements: `distrobuilder` (>= 3.0), `qemu-img`, `debootstrap`,
`btrfs-progs`, `rsync`, `tar`, `xz` (or run distrobuilder in a
privileged container).

```sh
# VM (cloud) image — amd64 or arm64 only
sudo distrobuilder build-incus images/debian.yaml --vm -o image.release=trixie -o image.architecture=amd64
sudo distrobuilder build-incus images/debian.yaml --vm -o image.release=trixie -o image.architecture=arm64

# Container image
sudo distrobuilder build-incus images/debian.yaml -o image.release=trixie -o image.architecture=amd64
```

This produces `incus.tar.xz` + `rootfs.qcow2` (VM) / `rootfs.squashfs`
(container) in the current directory.

Or use the wrapper:

```sh
./scripts/build.sh debian bullseye amd64        # Debian 11
./scripts/build.sh debian bookworm arm64        # Debian 12, arm64
./scripts/build.sh debian trixie amd64          # Debian 13
./scripts/build.sh ubuntu focal amd64           # Ubuntu 20.04
./scripts/build.sh ubuntu jammy arm64           # Ubuntu 22.04, arm64
./scripts/build.sh ubuntu noble amd64           # Ubuntu 24.04
./scripts/build.sh ubuntu resolute amd64        # Ubuntu 26.04
./scripts/build.sh ubuntu noble amd64 --container
```

## Publish (simplestreams)

Images are published to a static simplestreams tree with
`incus-simplestreams` (from the `incus-extra` package on Debian):

```sh
# pack a built image into the stream dir
./scripts/publish.sh ./incus.tar.xz ./rootfs.qcow2 solstice/debian/13/cloud

# serve the stream dir over https, then on each node:
incus remote add solstice https://<image-server>/ --protocol simplestreams
incus launch solstice:solstice/debian/13/cloud my-vm --vm
```

See `scripts/publish.sh` for the exact commands.

## Using with the Solstice panel

The [solstice panel](https://github.com/heyitslumi/solstice) lists cloud
images in the admin template form (image alias dropdown). Templates
pointing at `solstice/...` aliases are provisioned from the Solstice
image remote instead of `images.linuxcontainers.org`.

> Status: definitions + build/publish scripts only. The image server
> and panel wiring are not deployed yet — templates currently use
> upstream `images.linuxcontainers.org` aliases. Re-add the
> `solstice/` server selection in the panel API when hosting lands.

## Upstream

- Image definitions: https://github.com/lxc/lxc-ci/tree/main/images
- Builder: https://github.com/lxc/distrobuilder
- Official image server: https://images.linuxcontainers.org
- CI reference: https://jenkins.linuxcontainers.org/view/Images/

When upstream definitions change, re-sync `images/*.yaml` from
lxc-ci and re-apply the Solstice `files:` block at the top of the
`files:` list.
