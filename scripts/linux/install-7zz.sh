# linux/install-7zz.sh
bash <<'EOF'
set -euo pipefail

VERSION="26.00"
BASE_URL="https://sourceforge.net/projects/sevenzip/files/7-Zip/${VERSION}"
INSTALL_DIR="$HOME/.local/opt/7zip"
BIN_DIR="$HOME/.local/bin"
TMP_FILE="/tmp/7zip-linux.tar.xz"

if [ "$(id -u)" -ne 0 ]; then
  SUDO="sudo"
else
  SUDO=""
fi

ARCH="$(uname -m)"
case "$ARCH" in
  x86_64)
    PKG="7z2600-linux-x64.tar.xz"
    ;;
  aarch64)
    PKG="7z2600-linux-arm64.tar.xz"
    ;;
  *)
    echo "Unsupported arch: $ARCH"
    exit 1
    ;;
esac

$SUDO apt update
$SUDO apt install -y wget xz-utils

mkdir -p "$INSTALL_DIR" "$BIN_DIR"

wget -O "$TMP_FILE" "${BASE_URL}/${PKG}/download"
rm -rf "${INSTALL_DIR:?}"/*
tar -xJf "$TMP_FILE" -C "$INSTALL_DIR"
chmod +x "$INSTALL_DIR/7zz"
ln -sf "$INSTALL_DIR/7zz" "$BIN_DIR/7zz"

if ! grep -q 'export PATH="$HOME/.local/bin:$PATH"' "$HOME/.bashrc" 2>/dev/null; then
  echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
fi

export PATH="$HOME/.local/bin:$PATH"

echo
echo "Installed:"
"$BIN_DIR/7zz"
echo
echo "Try:"
echo "  7zz b -mmt=1"
echo "  7zz b -mmt=\$(nproc)"
EOF
