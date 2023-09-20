#!/bin/bash

set -ex

if [[ $(xcode-select -p) == "" ]]; then
  # install Mac dev tools
  xcode-select --install
  sleep 600
fi

if [ ! -d ~/.oh-my-zsh ]; then
  # install oh my zsh
  sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

if ! command -v brew; then
  # install Homebrew
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

if [ ! -f ~/.zshrc ]; then
  rm -rf ~/.zshrc
fi

if [ ! -d ~/.dotfiles ]; then 
  # clone the dotfiles repo
  git clone https://github.com/mihirsamdarshi/dotfiles ~/.dotfiles || echo "Already cloned"
fi

cd ~/.dotfiles || (echo ".dotfiles not cloned" && exit 1)

cp Brewfile ~/Brewfile
rm -f ~/.gitignore
cp .gitignore ~/.gitignore

mkdir -p ~/.config/omf/
mkdir -p ~/.config/fish/completions

# link all config files
# link fish config files
ln -sfv ~/.dotfiles/fish/conf/config.fish ~/.config/fish/config.fish
ln -sfv ~/.dotfiles/fish/functions ~/.config/fish/functions
ln -sfv ~/.dotfiles/fish/conf.d ~/.config/fish/conf.d
ln -sfv ~/.dotfiles/omf/bundle-linux ~/.config/omf/bundle
ln -sfv ~/.dotfiles/omf/channel ~/.config/omf/channel
ln -sfv ~/.dotfiles/omf/theme ~/.config/omf/theme
ln -sfv ~/.dotfiles/starship.toml ~/.config/starship.toml
# link tmux config
ln -sfv ~/.dotfiles/tmux/.tmux.conf ~/.tmux.conf
ln -sfv ~/.dotfiles/tmux/.tmux.conf.local ~/.tmux.conf.local

# link iterm2 config
ln -sfv ~/.dotfiles/iterm2 ~/.iterm2

# go back to the home directory
cd ~ || exit 1

# install files from Homebrew
brew bundle

git config --global user.name "Mihir Samdarshi"
git config --global user.email "mihirsamdarshi@users.noreply.github.com"

export NVM_DIR="$HOME/.nvm"
# shellcheck source=/dev/null
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

if ! command -v nvm &>/dev/null; then
  # install nvm
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
  export NVM_DIR="$HOME/.nvm"
  # shellcheck source=/dev/null
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
fi

if [ ! -f ~/.zshrc ]; then
  rm -f ~/.zshrc
fi

# install the latest version of Node
nvm install --lts
nvm use --lts
# install yarn
corepack enable

# add the pyenv stuff to the bashrc and profile
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

if ! command -v pyenv &>/dev/null; then
  {
    echo "export PYENV_ROOT=\"\$HOME/.pyenv\""
    echo "command -v pyenv >/dev/null || export PATH=\"\$PYENV_ROOT/bin:\$PATH\""
    echo "eval \"\$(pyenv init -)\""
  } >>~/.bashrc
  {
    echo "export PYENV_ROOT=\"\$HOME/.pyenv\""
    echo "command -v pyenv >/dev/null || export PATH=\"\$PYENV_ROOT/bin:\$PATH\""
    echo "eval \"\$(pyenv init -)\""
  } >>~/.zshrc
  {
    echo "export PYENV_ROOT=\"\$HOME/.pyenv\""
    echo "command -v pyenv >/dev/null || export PATH=\"\$PYENV_ROOT/bin:\$PATH\""
    echo "eval \"\$(pyenv init -)\""
  } >>~/.profile
fi

# install Python versions 3.8, 3.9, and 3.10 and set 3.10 to the global Python3 install
pyenv install -s 3.8.16
pyenv install -s 3.9.16
pyenv install -s 3.10.10
pyenv install -s 3.11.2
pyenv global 3.10.10

# Install Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --default-toolchain nightly --profile minimal -y
# shellcheck source=/dev/null
source "$HOME/.cargo/env"

rustup completions fish >~/.config/fish/completions/rustup.fish
mkdir -p ~/.zfunc
rustup completions zsh >~/.zfunc/_rustup

cargo install cargo-binstall
cargo binstall \
  action-validator cargo-about cargo-bloat cargo-bump cargo-deny \
  cargo-edit cargo-expand cargo-outdated cargo-release cargo-show-asm \
  cargo-udeps cargo-unused-features cargo-update cargo-watch cbindgen \
  erdtree flamegraph git-cliff grcov mozwire ouch tokio-console zoxide 

mkdir -p ~/.gitutils
wget https://repo1.maven.org/maven2/com/madgag/bfg/1.14.0/bfg-1.14.0.jar -o ~/.gitutils/bfg.jar

# install Oh My fish
fish setup.fish

# setup neovim
git clone https://github.com/NvChad/NvChad ~/.config/nvim --depth 1

# Download Google Cloud's database connectors
mkdir -p ~/.gcloud/
cd ~/.gcloud
wget https://storage.googleapis.com/cloud-sql-java-connector/v1.6.3/postgres-socket-factory-1.6.3-jar-with-dependencies.jar
wget https://storage.googleapis.com/cloud-sql-java-connector/v1.6.3/postgres-socket-factory-1.6.3-jar-with-driver-and-dependencies.jar
wget https://storage.googleapis.com/cloud-sql-java-connector/v1.6.3/mysql-socket-factory-1.6.3-jar-with-dependencies.jar
wget https://storage.googleapis.com/cloud-sql-java-connector/v1.6.3/mysql-socket-factory-1.6.3-jar-with-driver-and-dependencies.jar
