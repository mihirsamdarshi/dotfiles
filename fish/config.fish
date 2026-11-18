if status is-interactive
    if not test -e /proc/version
        # Added by OrbStack: command-line tools and integration
        # This won't be added again if you remove it.
        source ~/.orbstack/shell/init.fish 2>/dev/null || :
    else
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

