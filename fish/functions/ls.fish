function ls --wraps=exa --wraps='exa --long --git --icons --group-directories-first' --description 'alias ls exa --long --git --icons --group-directories-first'
  exa --long --git --icons --group-directories-first $argv
        
end
