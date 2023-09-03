function kjq --wraps 'kubectl get' -d "Kubernetes get and pipe to jq"
   if test (count $argv) -lt 3;
    kubectl get $argv[1] -o json | jq $argv[2]
  else
    kubectl get $argv[1] $argv[2] -o json | jq $argv[3..-1]
  end
end

