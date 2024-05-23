function make --wraps=make --description "make, but smarter"
    set original_dir (pwd) 
    set current_dir (pwd)
  
    while ! test -e $current_dir/Makefile
      if test $current_dir = /
           echo "Error: No Makefile found in parent directories."
           return 1
      end
      set current_dir (dirname $current_dir)
    end
  
    cd $current_dir
    command make $argv
    cd $original_dir
end

