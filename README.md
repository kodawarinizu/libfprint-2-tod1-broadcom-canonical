# libfprint-2-tod1-broadcom-canonical

Fallback PKGBUILD for the Dell fingerprint reader driver, sourced from
Canonical's Dell OEM archive when `git.launchpad.net` is unreachable.

## Quick Install

```bash
git clone https://github.com/kodawarinizu/libfprint-2-tod1-broadcom-canonical.git && cd libfprint-2-tod1-broadcom-canonical && makepkg -si
```

## Why this package exists

The original [`libfprint-2-tod1-broadcom`](https://aur.archlinux.org/packages/libfprint-2-tod1-broadcom)
AUR package pulls its source from Launchpad's git server. When that server
is down or unreachable, this package provides the same driver sourced
directly from Canonical's official Dell OEM pool
(`dell.archive.canonical.com`) instead.

## Source integrity

The tarball's SHA-256 checksum is pinned in the PKGBUILD (`sha256sums`).
`makepkg` will refuse to build if the downloaded file doesn't match.

## Conflicts

This package `provides`/`conflicts` with `libfprint-2-tod1-broadcom` to
avoid file collisions if both are installed. Only install one or the
other.

## License

Proprietary driver, distributed under Broadcom's own license terms — see
`LICENCE.broadcom` inside the extracted tarball, installed to
`/usr/share/licenses/libfprint-2-tod1-broadcom-canonical/LICENSE`.
