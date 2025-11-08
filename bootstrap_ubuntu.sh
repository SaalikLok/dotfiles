#!/usr/bin/env bash
set -e

echo "🐧 Saalik's Linux is getting setup..."

# Core packages via apt (excluding helix and kitty per your preferences)
sudo apt update
for tool in git stow fish; do
  if ! command -v $tool &> /dev/null; then
    echo "Installing $tool 🐧"
    sudo apt install -y $tool
  else
    echo "Already have $tool 🧬"
  fi
done

# Install Yazi (Debian/Ubuntu path)
if ! command -v yazi >/dev/null 2>&1; then
  echo "🦆 Installing Yazi (Debian/Ubuntu)"
  bash ./scripts/yazi_install.sh
else
  echo "Already have Yazi 🧬"
fi

# Helix from PPA (preferred source)
if ! command -v helix &> /dev/null && ! command -v hx &> /dev/null; then
  echo "📦 Adding Helix PPA and installing helix"
  sudo add-apt-repository -y ppa:maveonair/helix-editor
  sudo apt update
  sudo apt install -y helix
fi

# Kitty via official installer (not apt)
if ! command -v kitty &> /dev/null; then
  echo "😸 Installing Kitty via official installer..."
  curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
  # Ensure kitty/kitten are on PATH with system-recognized location
  mkdir -p ~/.local/bin
  ln -sf ~/.local/kitty.app/bin/kitty ~/.local/bin/kitty
  ln -sf ~/.local/kitty.app/bin/kitten ~/.local/bin/kitten

  # Install desktop file and icons so DE finds Kitty
  mkdir -p ~/.local/share/applications
  cp ~/.local/kitty.app/share/applications/kitty.desktop ~/.local/share/applications/
  cp ~/.local/kitty.app/share/icons/hicolor/256x256/apps/kitty.png ~/.local/share/icons/hicolor/256x256/apps/
  update-desktop-database ~/.local/share/applications || true
else
  echo "We've already got Kitty 😻"
fi

# Install mise (same on Linux)
if [ ! -x ~/.local/bin/mise ]; then
  echo "🥘 Installing mise"
  curl https://mise.run | sh
else
  echo "🥘 Mise is already installed"
fi

echo "🗃️ creating symlinks with Stow"
cd ~/.dotfiles
stow -R fish helix kitty yazi git mise

# Fisher and Fish plugins
if ! fish -c "type -q fisher" &> /dev/null; then
  echo "🎣 Installing Fisher"
  fish -c "curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher"
else
  echo "Fisher already installed"
fi

if [ -f ~/.config/fish/fish_plugins ]; then
  echo "Installing fish plugins"
  fish -c "fisher update"
else
  echo "🎣 No fish_plugins file found"
fi

# Set Fish as default shell if not already
if [ "$SHELL" != "$(which fish)" ]; then
  echo "🐚 Setting Fish as default shell..."
  if ! grep -q "$(which fish)" /etc/shells; then
    echo "$(which fish)" | sudo tee -a /etc/shells
  fi
  chsh -s "$(which fish)"
else
  echo "✅ Fish is already the default shell"
fi

# Install toolchains with Mise (run in fish context)
echo "🛠️  Installing language runtimes with Mise..."
fish -c "~/.local/bin/mise install"

echo ""
echo "⛰️ Good stuff. Setup complete."
echo ""
echo "Next steps:"
echo "  1. Close this and start Kitty."
echo "  2. Verify mise is working with: mise --version"
echo "  3. Check languages: mise list"
echo ""
