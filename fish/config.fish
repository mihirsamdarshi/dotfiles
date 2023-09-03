if status is-interactive
    if [ (uname -s) = "Darwin" ]
        if [ (uname -m) = "arm64" ]
            source /opt/homebrew/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.fish.inc
        else
            source /usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.fish.inc
        end

        test -e {$HOME}/.iterm2_shell_integration.fish ; and source {$HOME}/.iterm2_shell_integration.fish
        
        # connect home
        function wake_home
            tailscale up
            ssh pi@100.95.76.91 "wakeonlan 58:11:22:bb:7d:4f"
        end
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

    starship init fish | source

    # Shorthand for venv creation
    alias newvenv='python3 -m venv venv && source venv/bin/activate.fish && pip install --upgrade pip setuptools wheel'
    function gscatjq -d "Pipe the output of `gsutil cat` to jq"
      set JSON_FILE $argv[1]
      gsutil cat "$JSON_FILE" | jq $argv[2..-1]
    end

    function jqless -d "Pipe the output of jq to less"
      set JSON_FILE $argv[1]
     
      set JQ_ARGS "."

      if test (count $argv) -eq 2
        set JQ_ARGS $argv[2]
      end

      jq --color-output "$JQ_ARGS" "$JSON_FILE" | less --RAW-CONTROL-CHARS
    end
end

pyenv init - | source
