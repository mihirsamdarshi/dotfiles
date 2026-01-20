if status is-interactive
    if [ (uname -s) = Darwin ]
        test -e {$HOME}/.iterm2_shell_integration.fish; and source {$HOME}/.iterm2_shell_integration.fish
    else if [ (uname -s) = Linux ]
        alias pbcopy='xclip -sel clip'

        function podman -d "Podman is an open source container, pod, and container image management engine"
            if [ $argv[1] = compose ]
                podman-compose $argv[2..-1]
            else
                /usr/bin/podman $argv[1..-1]
            end
        end

        alias docker='podman'
    end
end

set GOPATH $HOME/.go

# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
source ~/.orbstack/shell/init.fish 2>/dev/null || :

# uv
fish_add_path "/Users/msamdarshi/.local/bin"

# Added by LM Studio CLI (lms)
set -gx PATH $PATH /Users/msamdarshi/.lmstudio/bin
# End of LM Studio CLI section
#
