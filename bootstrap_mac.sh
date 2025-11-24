#!/usr/bin/env bash

set -e # exit on error

echo "🍎 Saalik's Mac is getting setup..."

# check if homebrew is here
if ! command -v brew &> /dev/null; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
  echo "Homebrew's already installed 👍"
fi

# update homebrew
brew update

# let's install kitty
if ! command -v kitty &> /dev/null; then
  echo "😸 Installing Kitty..."
  curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
else
  echo "We've already got Kitty 😻"
fi

# core tools
for tool in fish stow git helix; do
  if ! command -v $tool &> /dev/null; then
    echo "Installing $tool 🐠"
    brew install $tool
  else
    echo "Already have $tool 🧬"
  fi
done

# check mise
if [ ! -x ~/.local/bin/mise ]; then
  echo "🥘 Installing mise"
  curl https://mise.run | sh
else
  echo "🥘 Mise is already installed"
fi

echo "🗃️ creating symlinks with Stow"
stow -R fish helix kitty git mise

# Fish plugins and Fisher
if ! fish -c "type -q fisher" &> /dev/null; then
  echo "Fisher being installed"
  fish -c echo '~/.local/bin/mise activate fish | source' >> ~/.config/fish/config.fish
else
  echo "Fisher already installed"
fi

# install fish plugins
if [ -f ~/.config/fish/fish_plugins ]; then
  echo "Installing fish plugins"
  fish -c "fisher update"
else
  echo "🎣 No fish_plugins file found"
fi

# Set Fish as default shell if not already
if [ "$SHELL" != "$(which fish)" ]; then
    echo "🐚 Setting Fish as default shell..."
    # Add fish to allowed shells if not already there
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
echo "  3. Check that we have all the languages we need: mise list"
echo ""
