function kj --wraps kubectl -d "Kubernetes commands but with -o json appended"
  kubectl $argv[1] $argv[2] -o json $argv[3..-1]
end

