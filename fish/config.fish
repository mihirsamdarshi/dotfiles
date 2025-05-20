if status is-interactive
    if [ (uname -s) = "Darwin" ]
        if [ (uname -m) = "arm64" ]
            source /opt/homebrew/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.fish.inc
        else
            source /usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.fish.inc
        end

        test -e {$HOME}/.iterm2_shell_integration.fish ; and source {$HOME}/.iterm2_shell_integration.fish
    else if [ (uname -s) = "Linux" ]
        alias pbcopy='xclip -sel clip'
        
        function podman -d "Podman is an open source container, pod, and container image management engine"
          if [ $argv[1] = "compose" ]
            podman-compose $argv[2..-1]
          else
            /usr/bin/podman $argv[1..-1]
          end
        end
        
        alias docker='podman'
    end
end

set GOPATH $HOME/.go

pyenv init - | source

# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
source ~/.orbstack/shell/init.fish 2>/dev/null || :

# Added by LM Studio CLI (lms)
set -gx PATH $PATH /Users/msamdars/.lmstudio/bin
