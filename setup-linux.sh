#!/bin/bash
set -e

IS_HEADLESS=0

if [ "$1" == "--headless" ]; then
  IS_HEADLESS=1
fi

if [ "$IS_HEADLESS" -eq 0 ]; then
  CONFIRM_MESSAGE="with a GUI"
else
  CONFIRM_MESSAGE="headlessly"
fi

read -p "Setting up Linux ${CONFIRM_MESSAGE}. Continue?:" ans_yn
case "$ans_yn" in
  [Yy]|[Yy][Ee][Ss]) echo "Setting up ${CONFIRM_MESSAGE}";;
  *) exit 1;;
esac

sudo apt update
sudo apt upgrade -y

sudo add-apt-repository -y ppa:neovim-ppa/unstable
sudo add-apt-repository -y ppa:fish-shell/release-3

sudo apt install -y tmux fish neovim fzf curl wget jq bc findutils gawk \
    software-properties-common lsb-release rsync

# developer libraries
sudo apt install -y python3-pip build-essential binutils libssl-dev \
    libwebkit2gtk-4.0-dev libgtk-3-dev libayatana-appindicator3-dev \
    librsvg2-dev libcairo2-dev libgdk-pixbuf-2.0-dev libdbus-1-dev \
    pkg-config p7zip-full parted util-linux zlib1g-dev libbz2-dev \
    libreadline-dev libsqlite3-dev libncursesw5-dev xz-utils tk-dev \
    libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev qemu-user-static

# sensors
sudo apt install -y lm-sensors neofetch htop

# set up repositories
sudo mkdir -p /etc/apt/keyrings

curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg 
sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
curl -fsSL https://download.opensuse.org/repositories/devel:kubic:libcontainers:unstable/xUbuntu_$(lsb_release -rs)/Release.key \
  | gpg --dearmor \
  | sudo tee /etc/apt/keyrings/devel_kubic_libcontainers_unstable.gpg > /dev/null

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/devel_kubic_libcontainers_unstable.gpg]\
    https://download.opensuse.org/repositories/devel:kubic:libcontainers:unstable/xUbuntu_$(lsb_release -rs)/ /" \
  | sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:unstable.list > /dev/null

sudo apt-get update
sudo apt-get install -y gh podman

if [ "$IS_HEADLESS" -eq 0 ]; then
  sudo apt install -y font-manager tilix conky-all

  sudo sh -c "echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/oracle-virtualbox-2016.gpg] https://download.virtualbox.org/virtualbox/debian $(lsb_release -sc) contrib' >> /etc/apt/sources.list"
  wget -O- https://www.virtualbox.org/download/oracle_vbox_2016.asc | sudo gpg --dearmor --yes --output /usr/share/keyrings/oracle-virtualbox-2016.gpg
  sudo apt-get update
  sudo apt -get install -y virtualbox-7.0
fi

# if the directory does not exist
if [ ! -d .dotfiles ]; then
  # clone the dotfiles repo
  git clone https://github.com/mihirsamdarshi/dotfiles .dotfiles
fi

cd .dotfiles || exit 1

rm -f ~/.gitignore
cp .gitignore ~/.gitignore

mkdir -p ~/.config/omf/
mkdir -p ~/.config/fish/

# link all config files
# link fish config files
ln -sfv fish/conf/config.fish ~/.config/fish/config.fish
ln -sfv fish/functions ~/.config/fish/functions
ln -sfv fish/conf.d ~/.config/fish/conf.d
ln -sfv omf/bundle-linux ~/.config/omf/bundle
ln -sfv omf/channel ~/.config/omf/channel
ln -sfv omf/theme ~/.config/omf/theme
ln -sfv starship.toml ~/.config/starship.toml
# link tmux config 
ln -sfv tmux/.tmux.conf ~/.tmux.conf
ln -sfv tmux/.tmux.conf.local ~/.tmux.conf.local

if [ "$IS_HEADLESS" -eq 0 ]; then
  mkdir -p ~/.config/kitty
  ln -sfv kitty/tab_bar.py ~/.config/kitty/tab_bar.py
  ln -sfv kitty/kitty.conf ~/.config/kitty/kitty.conf
  ln -sfv .conkyrc ~/.conkyrc
fi


export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

if ! command -v pyenv &> /dev/null ; then
  curl https://pyenv.run | bash
  echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc
  echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc
  echo 'eval "$(pyenv init -)"' >> ~/.bashrc

  echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.profile
  echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.profile
  echo 'eval "$(pyenv init -)"' >> ~/.profile
fi

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

if ! command -v nvm &> /dev/null ; then
  # install nvm
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
fi;

if [ ! -f ~/.zshrc ]; then
  rm -f ~/.zshrc
fi

# install the latest version of Node
nvm install --lts
# install yarn
corepack enable

# install Python versions 3.8, 3.9, and 3.10 and set 3.10 to the global Python3 install
pyenv install 3.8.11
pyenv install 3.9.10
pyenv install 3.10.10
pyenv install 3.11.2
pyenv global 3.10.10

# Install Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --default-toolchain nightly --profile minimal -y

rustup completions fish > ~/.config/fish/completions/rustup.fish
rustup completions zsh > ~/.zfunc/_rustup

cargo install cargo-expand cargo-flamegraph git-cliff tokio-console grcov cargo-edit

mkdir -p ~/.gitutils
wget https://repo1.maven.org/maven2/com/madgag/bfg/1.14.0/bfg-1.14.0.jar -o ~/.gitutils/bfg.jar

# install Oh My fish
fish setup.fish

# setup neovim
curl -s https://raw.githubusercontent.com/doom-neovim/doom-nvim/main/tools/install.sh | sh

