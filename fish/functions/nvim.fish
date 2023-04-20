function nvim --wraps=/opt/homebrew/bin/nvim --wraps='CC= /opt/homebrew/bin/nvim' --wraps=CC=\(brew\ unlink\ --dry-run\ gcc\ \|\ grep\ /opt/homebrew/bin\ \|\ grep\ \'\\/gcc-\\d\\d\'\)\ /opt/homebrew/bin/nvim --wraps='CC=/opt/homebrew/bin/gcc-12 /opt/homebrew/bin/nvim' --description 'alias nvim CC=/opt/homebrew/bin/gcc-12 /opt/homebrew/bin/nvim'
  CC=/opt/homebrew/bin/gcc-12 /opt/homebrew/bin/nvim $argv
        
end
