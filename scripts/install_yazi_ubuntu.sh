set -euo pipefail

install_yazi_release() {
  echo "⬇️  Installing Yazi from official release"
  tmp=$(mktemp -d)
  cd "$tmp"
  # Detect arch; adjust mapping if needed
  arch="$(uname -m)"
  case "$arch" in
    x86_64) asset="yazi-x86_64-unknown-linux-gnu.tar.gz" ;;
    aarch64|arm64) asset="yazi-aarch64-unknown-linux-gnu.tar.gz" ;;
    *) echo "Unsupported arch: $arch"; return 1 ;;
  esac

  # Resolve latest release tarball URL via GitHub releases API page
  curl -fsSL https://api.github.com/repos/sxyazi/yazi/releases/latest \
    | grep -oE "https://.+${asset}" | head -n1 | xargs -I{} curl -fsSL -o yazi.tar.gz {}
  mkdir yazi-temp && tar -xzf yazi.tar.gz -C yazi-temp
  sudo mv yazi-temp/*/{ya,yazi} /usr/local/bin
  rm -rf "$tmp"
  echo "✅ Yazi installed at /usr/local/bin/{yazi,ya}"
}

install_yazi_from_source() {
  echo "🦀 Building Yazi from source (fallback)"
  # Rust toolchain + build deps
  if ! command -v rustup >/dev/null 2>&1; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    export PATH="$HOME/.cargo/bin:$PATH"
  fi
  rustup update
  sudo apt-get update
  sudo apt-get install -y build-essential git
  # Fast path via yazi-build (installs yazi-fm and yazi-cli)
  cargo install --force yazi-build
  # Ensure both commands exist on PATH
  if ! command -v yazi >/dev/null 2>&1; then
    echo "yazi not on PATH; adding cargo bin symlinks"
    sudo ln -sf "$HOME/.cargo/bin/yazi" /usr/local/bin/yazi
  fi
  if ! command -v ya >/dev/null 2>&1; then
    sudo ln -sf "$HOME/.cargo/bin/ya" /usr/local/bin/ya
  fi
  echo "✅ Yazi built and installed"
}

install_yazi_optionals() {
  echo "📦 Installing Yazi optional utilities"
  # Debian/Ubuntu package names per docs
  sudo apt-get update
  sudo apt-get install -y ffmpeg 7zip jq poppler-utils fd-find ripgrep fzf zoxide imagemagick
  # fd binary is 'fdfind' on Debian; symlink to 'fd' for compatibility
  if command -v fdfind >/dev/null 2>&1 && ! command -v fd >/dev/null 2>&1; then
    sudo ln -sf "$(command -v fdfind)" /usr/local/bin/fd
  fi
  echo "ℹ️ Some Debian/Ubuntu versions ship older deps; if previews misbehave, consider newer builds. [Docs note]"
}

ensure_file_cmd() {
  # yazi relies on `file` for mime-type detection
  if ! command -v file >/dev/null 2>&1; then
    sudo apt-get update && sudo apt-get install -y file
  fi
}

main() {
  ensure_file_cmd
  # Try release first for speed; fall back to build if needed
  if ! install_yazi_release; then
    echo "⚠️ Release install failed; trying source build"
    install_yazi_from_source
  fi
  install_yazi_optionals
  yazi --version || true
}
main
