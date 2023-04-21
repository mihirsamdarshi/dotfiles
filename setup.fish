curl https://raw.githubusercontent.com/oh-my-fish/oh-my-fish/master/bin/install | fish

if [ (uname -s) = "Darwin" ]
    alias --save nvim "CC=$(brew unlink --dry-run gcc | grep "$(brew --prefix)/bin" | grep '\/gcc-\d\d') $(which nvim)"
else
    alias --save nvim nvim
end

omf install

