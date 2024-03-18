function gcrestart --description 'restart a google cloud instance'
    if test -n "$argv[3]"
        gcloud compute instances stop $argv[1] --project=$argv[2] --zone=$argv[3]
        gcloud compute instances start $argv[1] --project=$argv[2] --zone=$argv[3]
    else if test -n "$argv[2]"
        gcloud compute instances stop $argv[1] --project=$argv[2]
        gcloud compute instances start $argv[1] --project=$argv[2]
    else
        gcloud compute instances stop $argv[1]
        gcloud compute instances start $argv[1]
    end
end
