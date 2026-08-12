# Maintainer: Kodawarinizu (fallback package — original: Aaron Cottle)
pkgname=libfprint-2-tod1-broadcom-canonical
_ubaver="5.15.285-5.15.010.0"
pkgver=5.15.285.010.0
pkgrel=1
pkgdesc="Proprietary driver for the Dell fingerprint reader — sourced directly from Canonical's Dell OEM archive (fallback when git.launchpad.net is down)"
arch=(x86_64)
url="http://dell.archive.canonical.com/updates/pool/public/libf/libfprint-2-tod1-broadcom/"
license=(custom)
depends=(libfprint-tod)
provides=(libfprint-2-tod1-broadcom)
conflicts=(libfprint-2-tod1-broadcom)
source=("$pkgname-$_ubaver.orig.tar.gz::$url/${pkgname%-canonical}_$_ubaver.orig.tar.gz")
sha256sums=('67dc8dd47a58e0f9005a42b9bb7048345831257bfd28f34ddd0db1ef07a0e9bc')

prepare() {
  cd "$srcdir"
  rm -rf extracted
  mkdir -p extracted
  bsdtar -xf "$srcdir/$pkgname-$_ubaver.orig.tar.gz" -C extracted

  # Early validation: if Dell restructures the tarball, fail here with a clear message
  if ! find extracted -name "libfprint-2-tod-1-broadcom.so" | grep -q .; then
    echo "ERROR: .so binary not found after extraction. Check tarball structure." >&2
    exit 1
  fi
  if ! find extracted -name "LICENCE.broadcom" | grep -q .; then
    echo "ERROR: license file not found after extraction." >&2
    exit 1
  fi
}

package() {
  cd "$srcdir/extracted"

  install -dm 755 "$pkgdir/usr/lib/libfprint-2/tod-1/"
  install -dm 755 "$pkgdir/usr/lib/udev/rules.d/"
  install -dm 755 "$pkgdir/var/lib/fprint/fw/"

  find . -name "LICENCE.broadcom" -exec install -Dm 644 {} "$pkgdir/usr/share/licenses/$pkgname/LICENSE" \;
  find . -name "libfprint-2-tod-1-broadcom.so" -exec install -Dm 755 {} "$pkgdir/usr/lib/libfprint-2/tod-1/" \;

  if [ -d "lib/udev/rules.d" ]; then
    cp -r lib/udev/rules.d/* "$pkgdir/usr/lib/udev/rules.d/"
  fi
  if [ -d "var/lib/fprint/fw" ]; then
    cp -r var/lib/fprint/fw/* "$pkgdir/var/lib/fprint/fw/"
  fi
}
