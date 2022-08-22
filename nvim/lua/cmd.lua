local u = require('utils')

u.create_augroup({
  { 'BufEnter,FocusGained,InsertLeave,WinEnter * if &nu && mode() != "i" | set rnu | endif' },
  { 'BufLeave,FocusLost,InsertEnter,WinLeave * if &nu | set nornu | endif' }
}, 'numbertoggle')

