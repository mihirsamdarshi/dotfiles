curl https://raw.githubusercontent.com/oh-my-fish/oh-my-fish/master/bin/install | fish

alias --save fish "CC=$(brew unlink --dry-run gcc | grep "$(brew --prefix)/bin" | grep '\/gcc-\d\d') $(which nvim)"

omf install

