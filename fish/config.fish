if status is-interactive
    # Commands to run in interactive sessions can go here
end

# >>> mamba initialize >>>
# !! Contents within this block are managed by 'mamba init' !!
set -gx MAMBA_EXE "/home/lxm/.micromamba/bin/micromamba"
set -gx MAMBA_ROOT_PREFIX "/home/lxm/micromamba"
$MAMBA_EXE shell hook --shell fish --root-prefix $MAMBA_ROOT_PREFIX | source
# <<< mamba initialize <<<

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
if test -f /home/lxm/micromamba/bin/conda
    eval /home/lxm/micromamba/bin/conda "shell.fish" "hook" $argv | source
else
    if test -f "/home/lxm/micromamba/etc/fish/conf.d/conda.fish"
        . "/home/lxm/micromamba/etc/fish/conf.d/conda.fish"
    else
        set -x PATH "/home/lxm/micromamba/bin" $PATH
    end
end
# <<< conda initialize <<<

