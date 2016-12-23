for id in $(docker ps -aq); do docker rm -f $id; done
