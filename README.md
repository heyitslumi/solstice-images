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

| File | Image | Alias (planned) |
| --- | --- | --- |
| `images/debian.yaml` | Debian 13 (Trixie) cloud VM | `solstice/debian/13/cloud` |
| `images/ubuntu.yaml` | Ubuntu 24.04 LTS (Noble Numbat) cloud VM | `solstice/ubuntu/24.04/cloud` |

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
./scripts/build.sh debian trixie amd64          # VM image
./scripts/build.sh ubuntu noble arm64           # VM image, arm64
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
