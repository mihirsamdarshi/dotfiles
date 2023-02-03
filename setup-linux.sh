#!/bin/bash

set -e

sudo apt update
sudo apt upgrade -y

sudo add-apt-repository -y ppa:neovim-ppa/unstable
sudo add-apt-repository -y ppa:fish-shell/release-3

sudo apt install -y tmux fish neovim fzf curl wget jq bc findutils gawk software-properties-common font-manager lsb_release
# developer libraries
sudo apt install -y python3-pip build-essential binutils libssl-dev libwebkit2gtk-4.0-dev \
    libgtk-3-dev libayatana-appindicator3-dev librsvg2-dev pango gdk libcairo2-dev \
    libgdk-pixbuf-2.0-dev libgdk-pixbuf-2.0 gdk-pixbuf libdbus-1-dev pkg-config \
    p7zip-full parted util-linux zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev \
    libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev
# sensors
sudo apt install -y lm-sensors hddtemp tilix neofetch conky-all htop

sudo sh -c "echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/oracle-virtualbox-2016.gpg] https://download.virtualbox.org/virtualbox/debian $(lsb_release -sc) contrib' >> /etc/apt/sources.list"
wget -O- https://www.virtualbox.org/download/oracle_vbox_2016.asc | sudo gpg --dearmor --yes --output /usr/share/keyrings/oracle-virtualbox-2016.gpg
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg 
sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \

sudo apt-get update
sudo apt-get install virtualbox-7.0 gh

if ! [ -d ~/.oh-my-zsh ]; then 
# install oh my zsh
  sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi;


if ! [ command -v nvm ]; then
  # install nvm
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
fi;

if [ ! -f ~/.zshrc ]; then
  rm -rf ~/.zshrc
fi

# clone the dotfiles repo
git clone https://github.com/mihirsamdarshi/dotfiles .dotfiles && cd .dotfiles || exit 1

rm ~/.gitignore
cp .gitignore ~/.gitignore

mkdir -p ~/.config/omf/
mkdir -p ~/.config/nvim/
mkdir -p ~/.config/fish/

cp -r fish ~/.config/fish
cp -r omf ~/.config/omf
cp -r nvim ~/.config/nvim

ln -s ~/.config/nvim/init.lua ~/.vimrc

cp starship.toml ~/.config/starship.toml

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

# install Oh My fish
curl https://raw.githubusercontent.com/oh-my-fish/oh-my-fish/master/bin/install | fish
