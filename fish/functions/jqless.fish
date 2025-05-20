function jqless -d "Pipe the output of jq to less"
  set JSON_FILE $argv[1]
 
  set JQ_ARGS "."

  if test (count $argv) -eq 2
    set JQ_ARGS $argv[2]
  end

  jq --color-output "$JQ_ARGS" "$JSON_FILE" | less --RAW-CONTROL-CHARS
end

