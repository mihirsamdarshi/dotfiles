if status is-interactive
    source /usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.fish.inc
end

starship init fish | source
eval "$(pyenv init -)"

test -e {$HOME}/.iterm2_shell_integration.fish ; and source {$HOME}/.iterm2_shell_integration.fish

# Shorthand for venv creation
alias newvenv='python3 -m venv venv && source venv/bin/activate.fish && pip install --upgrade pip setuptools wheel'

alias gscatjq=gsutilcatpipetojq

function gsutilcatpipetojq
  set JSON_FILE $argv[1]
  gsutil cat "$JSON_FILE" | jq $argv[2..-1]
end


