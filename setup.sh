#!/bin/bash

set -e

# install Mac dev tools
xcode-select --install

# install oh my zsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
# install nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

if [ ! -f ~/.zshrc ]; then
  rm -rf ~/.zshrc
fi

# clone the dotfiles repo
git clone https://github.com/mihirsamdarshi/dotfiles . && cd dotfiles || exit 1

cp .Brewfile ~/.Brewfile
mkdir -p ~/.config/omf/
mkdir -p ~/.config/nvim/
mkdir -p ~/.config/fish/

cp -r fish ~/.config/fish
cp -r omf ~/.config/omf
cp -r nvim ~/.config/nvim

ln -s ~/.config/nvim/init.lua ~/.vimrc

cp starship.toml ~/.config/starship.toml

brew bundle 

# install Oh My fish
curl https://raw.githubusercontent.com/oh-my-fish/oh-my-fish/master/bin/install | fish

# install the latest version of Node
nvm install --lts
# install yarn
corepack enable

# install Python versions 3.8, 3.9, and 3.10 and set 3.10 to the global Python3 install
pyenv install 3.8.11
pyenv install 3.9.10
pyenv install 3.10.4
pyenv global 3.10.11

# Install Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --default-toolchain nightly --profile minimal -y

rustup completions fish > ~/.config/fish/completions/rustup.fish
rustup completions zsh > ~/.zfunc/_rustup

cargo install cargo-expand cargo-flamegraph git-cliff tokio-console grcov cargo-edit

mkdir -p ~/.gitutils
wget https://repo1.maven.org/maven2/com/madgag/bfg/1.14.0/bfg-1.14.0.jar -o ~/.gitutils/bfg.jar

mkdir -p ~/.gcloud/
cd ~/.gcloud
wget https://storage.googleapis.com/cloud-sql-java-connector/v1.6.3/postgres-socket-factory-1.6.3-jar-with-dependencies.jar
wget https://storage.googleapis.com/cloud-sql-java-connector/v1.6.3/postgres-socket-factory-1.6.3-jar-with-driver-and-dependencies.jar
wget https://storage.googleapis.com/cloud-sql-java-connector/v1.6.3/mysql-socket-factory-1.6.3-jar-with-dependencies.jar
wget https://storage.googleapis.com/cloud-sql-java-connector/v1.6.3/mysql-socket-factory-1.6.3-jar-with-driver-and-dependencies.jar

