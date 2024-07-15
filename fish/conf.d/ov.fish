# Check if `ov` is installed, if it is, export PAGER to `ov`
if command -v ov >/dev/null 2>&1;
    export PAGER='ov -F'
end

