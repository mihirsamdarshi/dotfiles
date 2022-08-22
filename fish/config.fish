if status is-interactive
    source /usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.fish.inc
end

starship init fish | source
eval "$(pyenv init -)"

test -e {$HOME}/.iterm2_shell_integration.fish ; and source {$HOME}/.iterm2_shell_integration.fish

# Shorthand for venv creation
alias newvenv='python3 -m venv venv && source venv/bin/activate.fish && pip install --upgrade pip setuptools wheel'
alias ls=exa
alias vim=nvim

alias gscatjq=gsutilcatpipetojq

function gsutilcatpipetojq
  set JSON_FILE $argv[1]
  gsutil cat "$JSON_FILE" | jq $argv[2..-1]
end

function mkdir -d "Create a directory and set CWD"
    command mkdir $argv
    if test $status = 0
        switch $argv[(count $argv)]
            case '-*'

            case '*'
                cd $argv[(count $argv)]
                return
        end
    end
end


