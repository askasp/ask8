kubectl create secret generic regcred \
    --from-file=.dockerconfigjson=/home/ask/.docker/config.json \
    --type=kubernetes.io/dockerconfigjson
