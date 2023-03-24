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
		gui)
			IS_HEADLESS=false
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
	l)
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

function wait_for_apt() {
	while sudo fuser /var/{lib/{dpkg,apt/lists},cache/apt/archives}/lock >/dev/null 2>&1; do
		sleep 1
	done
}

sudo apt-get update
wait_for_apt

sudo apt-get upgrade -y
wait_for_apt

sudo add-apt-repository -y ppa:neovim-ppa/unstable
sudo add-apt-repository -y ppa:fish-shell/release-3
sudo add-apt-repository -y ppa:agornostal/ulauncher
wait_for_apt

sudo apt-get install -y tmux fish neovim fzf curl wget jq bc findutils gawk \
	software-properties-common lsb-release rsync exa ripgrep nvme-cli ulauncher \
	openssh-server
wait_for_apt

# developer libraries
sudo apt-get install -y python3-pip build-essential binutils libssl-dev \
	libwebkit2gtk-4.0-dev libgtk-3-dev libayatana-appindicator3-dev \
	librsvg2-dev libcairo2-dev libgdk-pixbuf-2.0-dev libdbus-1-dev \
	pkg-config p7zip-full parted util-linux zlib1g-dev libbz2-dev \
	libreadline-dev libsqlite3-dev libncursesw5-dev xz-utils tk-dev \
	libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev qemu-user-static \
	linux-tools-common linux-tools-generic
wait_for_apt

# sensors
sudo apt-get install -y lm-sensors neofetch htop
wait_for_apt

# set up repositories
sudo mkdir -p /etc/apt/keyrings

# add the GitHub CLI repository
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null
wait_for_apt

# add the Podman repository
curl -fsSL "https://download.opensuse.org/repositories/devel:kubic:libcontainers:unstable/xUbuntu_$(lsb_release -rs)/Release.key" |
	gpg --dearmor |
	sudo tee /etc/apt/keyrings/devel_kubic_libcontainers_unstable.gpg >/dev/null
echo \
	"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/devel_kubic_libcontainers_unstable.gpg]\
    https://download.opensuse.org/repositories/devel:kubic:libcontainers:unstable/xUbuntu_$(lsb_release -rs)/ /" |
	sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:unstable.list >/dev/null
wait_for_apt

# install the Azul repository
curl -s https://repos.azul.com/azul-repo.key | sudo gpg --dearmor -o /usr/share/keyrings/azul.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/azul.gpg] https://repos.azul.com/zulu/deb stable main" | sudo tee /etc/apt/sources.list.d/zulu.list
wait_for_apt

sudo apt-get update
wait_for_apt

sudo apt-get install -y gh podman zulu17-jdk
wait_for_apt

if [ "$IS_HEADLESS" == 0 ]; then
	sudo apt-get install -y font-manager tilix conky-all
	wait_for_apt

	# add the VirtualBox repository
	sudo sh -c "echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/oracle-virtualbox-2016.gpg] https://download.virtualbox.org/virtualbox/debian $(lsb_release -sc) contrib' >> /etc/apt/sources.list"
	wget -O- https://www.virtualbox.org/download/oracle_vbox_2016.asc | sudo gpg --dearmor --yes --output /usr/share/keyrings/oracle-virtualbox-2016.gpg
	sudo apt-get update
	wait_for_apt

	sudo apt-get install -y virtualbox-7.0
fi

git config --global user.name "Mihir Samdarshi"
git config --global user.email "mihirsamdarshi@users.noreply.github.com"

# if the directory does not exist
if [ ! -d .dotfiles ]; then
	# clone the dotfiles repo
	git clone git@github.com:mihirsamdarshi/dotfiles .dotfiles
fi

rm -f ~/.gitignore

mkdir -p ~/.config/omf/
mkdir -p ~/.config/fish/completions

function create_link() {
	local original_file
	local new_link

	original_file=$1
	new_link=$2

	if [ -L "$new_link" ]; then
		if [ -e "$new_link" ]; then
			echo "$new_link already exists, doing nothing"
		else
			echo "$new_link is broken, unlinking and recreating"
			unlink "$new_link"
            ln -sfv "$original_file" "$new_link"
		fi
	elif [ -e "$new_link" ]; then
		echo "$new_link is not a link, removing it and creating a symlink"
		rm -rf "$new_link"
        ln -sfv "$original_file" "$new_link"
	else
		echo "$new_link missing, linking to $original_file..."
		ln -sfv "$original_file" "$new_link"
	fi
}

# link all config files
create_link ~/.dotfiles/.gitignore ~/.gitignore
# link fish config files
create_link ~/.dotfiles/fish/conf/config.fish ~/.config/fish/config.fish
create_link ~/.dotfiles/fish/functions ~/.config/fish/functions
create_link ~/.dotfiles/fish/conf.d ~/.config/fish/conf.d
create_link ~/.dotfiles/omf/bundle-linux ~/.config/omf/bundle
create_link ~/.dotfiles/omf/channel ~/.config/omf/channel
create_link ~/.dotfiles/omf/theme ~/.config/omf/theme
create_link ~/.dotfiles/starship.toml ~/.config/starship.toml
# link tmux config
create_link ~/.dotfiles/tmux/.tmux.conf ~/.tmux.conf
create_link ~/.dotfiles/tmux/.tmux.conf.local ~/.tmux.conf.local

if [ "$IS_HEADLESS" == 0 ]; then
	mkdir -p ~/.config/kitty
	create_link ~/.dotfiles/kitty/tab_bar.py ~/.config/kitty/tab_bar.py
	create_link ~/.dotfiles/kitty/kitty.conf ~/.config/kitty/kitty.conf
	create_link ~/.dotfiles/.conkyrc ~/.conkyrc
fi


if [ -d ~/.pyenv ]; then
	rm -rf ~/.pyenv
fi

export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"

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

eval "$(pyenv init -)"

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
# shellcheck source=/dev/null
source "$HOME/.cargo/env"

rustup completions fish >~/.config/fish/completions/rustup.fish

cargo install cargo-binstall
cargo binstall cargo-expand flamegraph git-cliff tokio-console grcov cargo-edit cargo-watch cargo-update zoxide bat fd-find

mkdir -p ~/.gitutils
wget https://repo1.maven.org/maven2/com/madgag/bfg/1.14.0/bfg-1.14.0.jar -O ~/.gitutils/bfg.jar

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
