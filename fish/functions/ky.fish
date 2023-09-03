function ky --wraps kubectl -d "Kubernetes commands but with -o yaml appended"
  kubectl $argv[1] $argv[2] -o yaml $argv[3..-1]
end

