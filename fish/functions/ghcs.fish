# ~/.config/fish/functions/ghcs.fish
function ghcs --description 'Wrapper around `gh copilot suggest` to generate a shell/gh/git command from a natural-language prompt.' --argument-names prompt
    set -l TARGET shell
    set -l GH_DEBUG $GH_DEBUG
    set -l GH_HOST $GH_HOST

    # note: -N 1 comes immediately after -n
    argparse -n ghcs -N 1 \
        d/debug \
        h/help \
        'hostname=' \
        't/target=' \
        -- $argv; or return

    if set -q _flag_help
        functions -d ghcs # shows the --description text
        return 0
    end

    if set -q _flag_debug
        set GH_DEBUG api
    end
    if set -q _flag_hostname
        set GH_HOST $_flag_hostname
    end
    if set -q _flag_target
        set TARGET $_flag_target
    end

    set -l TMPFILE (mktemp -t gh-copilotXXXXXX)
    function __ghcs_cleanup --on-event fish_exit
        rm -f $TMPFILE
    end

    if env GH_DEBUG=$GH_DEBUG GH_HOST=$GH_HOST \
            gh copilot suggest -t $TARGET $argv --shell-out $TMPFILE
        if test -s $TMPFILE
            set -l FIXED_CMD (cat $TMPFILE)
            echo
            eval -- $FIXED_CMD
        end
    else
        return 1
    end
end
