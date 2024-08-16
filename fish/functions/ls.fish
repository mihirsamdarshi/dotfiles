function ls --wraps=eza --wraps='exa --long --git --icons --group-directories-first' --description 'alias ls eza --long --git --icons --group-directories-first'
  eza --long --git --icons --group-directories-first $argv
end
