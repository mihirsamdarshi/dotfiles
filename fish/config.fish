if [ (uname -s) = "Darwin" ]
    if status is-interactive
        source /usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.fish.inc
    end
    
    test -e {$HOME}/.iterm2_shell_integration.fish ; and source {$HOME}/.iterm2_shell_integration.fish
else if [ (uname -s) = "Linux" ]
    alias pbcopy='xclip -sel clip'
end

starship init fish | source
eval "$(pyenv init -)"


# Shorthand for venv creation
alias newvenv='python3 -m venv venv && source venv/bin/activate.fish && pip install --upgrade pip setuptools wheel'

alias gscatjq=gsutilcatpipetojq

function gsutilcatpipetojq
  set JSON_FILE $argv[1]
  gsutil cat "$JSON_FILE" | jq $argv[2..-1]
end


