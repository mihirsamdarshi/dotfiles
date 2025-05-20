function gscatjq -d "Pipe the output of `gsutil cat` to jq"
  set JSON_FILE $argv[1]
  gcloud storage cat "$JSON_FILE" | jq $argv[2..-1]
end

