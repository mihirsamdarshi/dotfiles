function kall 
  for i in (kubectl api-resources --verbs=list --namespaced -o name | grep -v "events.events.k8s.io" | grep -v "events" | sort | uniq)
    echo "Resource:" $i

    if test -z $argv[1]
        kubectl get --ignore-not-found $i
    else
        kubectl -n $argv[1] get --ignore-not-found $i
    end
  end
end

