#!/usr/bin/env bash
set -euo pipefail

BASE_URL="http://dell.archive.canonical.com/updates/pool/public/libf/libfprint-2-tod1-broadcom"
PKGBUILD="PKGBUILD"

current_ubaver=$(grep -oP '_ubaver="\K[^"]+' "$PKGBUILD")

# 1. Obtener el listado del index y extraer la última versión .orig.tar.gz
latest_file=$(curl -fsSL "$BASE_URL/" \
  | grep -oP 'libfprint-2-tod1-broadcom_\K[0-9.\-]+(?=\.orig\.tar\.gz)' \
  | sort -V | tail -n1)

if [[ "$latest_file" == "$current_ubaver" ]]; then
  echo "updated=false" >> "$GITHUB_OUTPUT"
  echo "Sin cambios, versión actual sigue vigente."
  exit 0
fi

echo "Nueva versión detectada: $latest_file (actual: $current_ubaver)"

tarball="libfprint-2-tod1-broadcom_${latest_file}.orig.tar.gz"
dsc="libfprint-2-tod1-broadcom_${latest_file}-0ubuntu2~22.04.1~oem1.dsc"

# 2. Descargar tarball y .dsc
curl -fsSL -o "$tarball" "$BASE_URL/$tarball"
curl -fsSL -o "$dsc" "$BASE_URL/$dsc" || {
  echo "::warning::No se pudo obtener .dsc para verificación cruzada. Abortando por seguridad."
  exit 1
}

# 3. Calcular hash local
computed_hash=$(sha256sum "$tarball" | awk '{print $1}')

# 4. Extraer el hash declarado dentro del .dsc
declared_hash=$(awk '/^Checksums-Sha256:/{flag=1;next} /^Checksums-Sha1:|^Files:/{flag=0} flag' "$dsc" \
  | grep "$tarball" | awk '{print $1}')

if [[ -z "$declared_hash" ]]; then
  echo "::error::No se encontró el hash declarado en el .dsc. Abortando."
  exit 1
fi

if [[ "$computed_hash" != "$declared_hash" ]]; then
  echo "::error::MISMATCH — el hash del tarball descargado NO coincide con el declarado en el .dsc."
  echo "Calculado: $computed_hash"
  echo "Declarado: $declared_hash"
  exit 1
fi

echo "Hash verificado contra .dsc: $computed_hash"

# 5. Chequeo de tamaño anómalo (sanity check)
new_size=$(stat -c%s "$tarball")
old_size=$(stat -c%s "$(ls libfprint-2-tod1-broadcom-*.orig.tar.gz 2>/dev/null | head -1 || echo /dev/null)" 2>/dev/null || echo 0)

# 6. Actualizar el PKGBUILD
new_pkgver=$(echo "$latest_file" | sed 's/-/./g')
sed -i "s/_ubaver=\"[^\"]*\"/_ubaver=\"$latest_file\"/" "$PKGBUILD"
sed -i "s/^pkgver=.*/pkgver=$new_pkgver/" "$PKGBUILD"
sed -i "s/^pkgrel=.*/pkgrel=1/" "$PKGBUILD"
sed -i "s/sha256sums=('[^']*')/sha256sums=('$computed_hash')/" "$PKGBUILD"

echo "updated=true" >> "$GITHUB_OUTPUT"
echo "old_version=$current_ubaver" >> "$GITHUB_OUTPUT"
echo "new_version=$latest_file" >> "$GITHUB_OUTPUT"
echo "old_size=${old_size}" >> "$GITHUB_OUTPUT"
echo "new_size=${new_size}" >> "$GITHUB_OUTPUT"
