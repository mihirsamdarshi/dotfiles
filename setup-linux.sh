#!/bin/bash
set -e

IS_HEADLESS=0

if [ "$1" == "--headless" ]; then
  IS_HEADLESS=1
fi

if [ "$IS_HEADLESS" -eq 0 ]; then
  CONFIRM_MESSAGE="with a GUI" else
  CONFIRM_MESSAGE="headlessly"
fi

read -rp "Setting up Debian-flavored install ${CONFIRM_MESSAGE}. Continue?:" ans_yn
case "$ans_yn" in
[Yy] | [Yy][Ee][Ss]) echo "Setting up ${CONFIRM_MESSAGE}" ;;
*) exit 1 ;;
esac

sudo apt-get update
sudo apt-get upgrade -y
sudo add-apt-repository -y ppa:neovim-ppa/unstable
sudo add-apt-repository -y ppa:fish-shell/release-3
sudo add-apt-repository ppa:agornostal/ulauncher

sudo apt-get install -y tmux fish neovim fzf curl wget jq bc findutils gawk \
  software-properties-common lsb-release rsync exa ripgrep nvme-cli ulauncher

# developer libraries
sudo apt-get install -y python3-pip build-essential binutils libssl-dev \
  libwebkit2gtk-4.0-dev libgtk-3-dev libayatana-appindicator3-dev \
  librsvg2-dev libcairo2-dev libgdk-pixbuf-2.0-dev libdbus-1-dev \
  pkg-config p7zip-full parted util-linux zlib1g-dev libbz2-dev \
  libreadline-dev libsqlite3-dev libncursesw5-dev xz-utils tk-dev \
  libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev qemu-user-static \
  linux-tools-common linux-tools-generic
# sensors
sudo apt-get install -y lm-sensors neofetch htop

# set up repositories
sudo mkdir -p /etc/apt/keyrings

# add the GitHub CLI repository
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null
# add the Podman repository
curl -fsSL "https://download.opensuse.org/repositories/devel:kubic:libcontainers:unstable/xUbuntu_$(lsb_release -rs)/Release.key" |
  gpg --dearmor |
  sudo tee /etc/apt/keyrings/devel_kubic_libcontainers_unstable.gpg >/dev/null
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/devel_kubic_libcontainers_unstable.gpg]\
    https://download.opensuse.org/repositories/devel:kubic:libcontainers:unstable/xUbuntu_$(lsb_release -rs)/ /" |
  sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:unstable.list >/dev/null
# install the Azul repository
curl -s https://repos.azul.com/azul-repo.key | sudo gpg --dearmor -o /usr/share/keyrings/azul.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/azul.gpg] https://repos.azul.com/zulu/deb stable main" | sudo tee /etc/apt/sources.list.d/zulu.list

sudo apt-get update
sudo apt-get install -y gh podman zulu17-jdk

if [ "$IS_HEADLESS" -eq 0 ]; then
  sudo apt install -y font-manager tilix conky-all

  sleep 20
  # add the VirtualBox repository
  sudo sh -c "echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/oracle-virtualbox-2016.gpg] https://download.virtualbox.org/virtualbox/debian $(lsb_release -sc) contrib' >> /etc/apt/sources.list"
  wget -O- https://www.virtualbox.org/download/oracle_vbox_2016.asc | sudo gpg --dearmor --yes --output /usr/share/keyrings/oracle-virtualbox-2016.gpg
  sudo apt-get update
  sudo apt -get install -y virtualbox-7.0
fi

git config --global user.name "Mihir Samdarshi"
git config --global user.email "mihirsamdarshi@users.noreply.github.com"

# if the directory does not exist
if [ ! -d .dotfiles ]; then
  # clone the dotfiles repo
  git clone git@github.com:mihirsamdarshi/dotfiles .dotfiles
fi

cd .dotfiles || exit 1

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

if [ "$IS_HEADLESS" -eq 0 ]; then
  mkdir -p ~/.config/kitty
  ln -sfv ~/.dotfiles/kitty/tab_bar.py ~/.config/kitty/tab_bar.py
  ln -sfv ~/.dotfiles/kitty/kitty.conf ~/.config/kitty/kitty.conf
  ln -sfv ~/.dotfiles/.conkyrc ~/.conkyrc
fi

export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

if ! command -v pyenv &>/dev/null; then
  curl https://pyenv.run | bash
  {
    echo "export PYENV_ROOT=\"\$HOME/.pyenv\""
    echo "command -v pyenv >/dev/null || export PATH=\"\$PYENV_ROOT/bin:\$PATH\""
    echo "eval \"\$(pyenv init -)\""
  } >>~/.bashrc
  {
    echo "export PYENV_ROOT=\"\$HOME/.pyenv\""
    echo "command -v pyenv >/dev/null || export PATH=\"\$PYENV_ROOT/bin:\$PATH\""
    echo "eval \"\$(pyenv init -)\""
  } >>~/.profile
fi

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

# install the latest version of Node
nvm install --lts
nvm use --lts
# install yarn
corepack enable

# install Python versions 3.8, 3.9, and 3.10 and set 3.10 to the global Python3 install
pyenv install -s 3.8.16
pyenv install -s 3.9.16
pyenv install -s 3.10.10
pyenv install -s 3.11.2
pyenv global 3.10.10

# Install Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --default-toolchain nightly --profile minimal -y

rustup completions fish >~/.config/fish/completions/rustup.fish
# shellcheck source=/dev/null
source "$HOME/.cargo/env"

cargo install cargo-binstall
cargo binstall cargo-expand flamegraph git-cliff tokio-console grcov cargo-edit cargo-watch cargo-update zoxide bat fd-find

mkdir -p ~/.gitutils
wget https://repo1.maven.org/maven2/com/madgag/bfg/1.14.0/bfg-1.14.0.jar -o ~/.gitutils/bfg.jar

# install Oh My fish
fish setup.fish

# install kinto/xkeysnail for Mac Keyboard remapping 
/bin/bash -c "$(wget -qO- https://raw.githubusercontent.com/rbreaves/kinto/HEAD/install/linux.sh)"
echo "IMPORTANT: Remember to edit device list with the proper Logitech keyboard"

# setup neovim
curl -s https://raw.githubusercontent.com/doom-neovim/doom-nvim/main/tools/install.sh | bash
cd ~/.config/nvim/ || echo "$HOME/.config/nvim/ folder not found" && exit 1
git apply ~/.dotfiles/nvim/doom-nvim.patch
