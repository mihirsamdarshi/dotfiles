#!/bin/bash
set -e

IS_HEADLESS=0
HOSTNAME=0
SETUP_TAILSCALE=false

optspec=":hnt-:"
while getopts "$optspec" optchar; do
	case "${optchar}" in
	-)
		case "${OPTARG}" in
		hostname)
			val="${!OPTIND}"
			OPTIND=$((OPTIND + 1))
			HOSTNAME=$val
			;;
		hostname=*)
			val=${OPTARG#*=}
			HOSTNAME=$val
			;;
		headless)
			IS_HEADLESS=true
			;;
		tailscale)
			SETUP_TAILSCALE=true
			;;
		*)
			if [ "$OPTERR" = 1 ] && [ "${optspec:0:1}" != ":" ]; then
				echo "Unknown option --${OPTARG}" >&2
			fi
			;;
		esac
		;;
	h)
		IS_HEADLESS=true
		;;
	n)
		HOSTNAME="${!OPTIND}"
		shift
		;;
	t)
		SETUP_TAILSCALE=true
		;;
	\?)
		echo "Invalid option -$OPTARG" >&2
		exit 1
		;;
	esac
done
shift $((OPTIND - 1))

if [ "$HOSTNAME" == 0 ]; then
	HOSTNAME_MESSAGE="Not setting a hostname"
else
	HOSTNAME_MESSAGE="Setting hostname to $HOSTNAME"
fi

if [ $SETUP_TAILSCALE == true ]; then
	TAILSCALE_MESSAGE="Setting up tailscale"
else
	TAILSCALE_MESSAGE="Not setting up tailscale"
fi

if [ "$IS_HEADLESS" == 0 ]; then
	while [ "$IS_HEADLESS" == 0 ]; do
		read -rp "Are you setting up headless or gui?: " ans_yn
		case "$ans_yn" in
		headless)
			IS_HEADLESS=true
			;;
		gui)
			IS_HEADLESS=false
			;;
		*) echo "Only \"headless\" and \"gui\" are valid options" ;;
		esac
	done
fi

if [ "$IS_HEADLESS" == true ]; then
	CONFIRM_MESSAGE="Setting up headless Debian-flavored install"
else
	CONFIRM_MESSAGE="Setting up Debian-flavored install with a GUI"
fi

read -rp "${CONFIRM_MESSAGE}. $HOSTNAME_MESSAGE. $TAILSCALE_MESSAGE. Continue? (y/n): " ans_yn
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
	software-properties-common lsb-release rsync exa ripgrep nvme-cli ulauncher \
	openssh-server

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

# install tailscale
if [ "$SETUP_TAILSCALE" == true ]; then
	curl -fsSL https://tailscale.com/install.sh | sh
fi

if [ "$IS_HEADLESS" == false ]; then
	# install kinto/xkeysnail for Mac Keyboard remapping
	/bin/bash -c "$(wget -qO- https://raw.githubusercontent.com/rbreaves/kinto/HEAD/install/linux.sh)"
	echo "IMPORTANT: Remember to edit device list with the proper Logitech keyboard"

	# use ssh socket on GUI systems
	if [ "$(systemctl is-active ssh.socket)" == "inactive" ]; then
		sudo systemctl disable ssh
		sudo systemctl stop ssh
		sudo systemctl enable ssh.socket
		sudo systemctl start ssh.socke
	fi
	# set up no sleep service when SSH session is active
	cat <<EOF >/etc/systemd/system/ssh-no-sleep@.service
[Unit]
Description=ssh no sleep
BindsTo=ssh@%i.service

[Service]
ExecStart=/usr/bin/systemd-inhibit --mode block --what sleep --who "ssh session "%I --why "session still active" /usr/bin/sleep infinity

[Install]
WantedBy=ssh@.Service
EOF

	sudo systemctl enable ssh-no-sleep@
	sudo systemctl daemon-reload
	sudo systemctl restart ssh-no-sleep@.service
fi

# setup neovim
curl -s https://raw.githubusercontent.com/doom-neovim/doom-nvim/main/tools/install.sh | bash
cd ~/.config/nvim/ || echo "$HOME/.config/nvim/ folder not found" && exit 1
git apply ~/.dotfiles/nvim/doom-nvim.patch
