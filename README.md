# Simpk8s- the poor mans alternative

It runs on a single digital ocean droplet.
Meaning that it costs the same as a VM.
This gives significantly more bang for the buck as you
do not need a load balancer, something that is required for 
managed k8s.


## How to use
### Connecting 
    1. Send ssh pub key to aksel
    2. Copy ~/.kube/config from remote to local
        ~/.kube/config
    3. Open a tunnel with ssh -N -L localhost:16443:localhost:16443 root@167.99.218.91
    4. Use kubectl as normal from your terminal
    
    might need this (I didnt)
    sed -ie "s/127.0.0.1/$SERVERIP/g" ~/.kube/config
    
### Namespaces
We have one namespace for dev and one for production so 
we can run both in the same cluster

<img src="https://i.imgur.com/GmlvwmI.jpeg" alt="drawing" width="400"/>

Change between them 

    kubectl config use-context dev
    kubectl config use-context prod


### Kubernetes dashboard 
    ssh root@droplet
    token=$(microk8s kubectl -n kube-system get secret | grep default-token | cut -d " " -f1)
    microk8s kubectl -n kube-system describe secret $token
    
Copy token to clipboard and enter it at  https://dashboard.ask8.stadler.no/#/login
    
    
### Flex Elixir dashboard
Will put this behind an admin login when we have it
    https://dev-abbo.stadler.no/dashboard
    


### SimpCI with github action

In this repo:
Add a deployment, and service + ingress if wanted.
Deploy that manually (one time thing). 

In app repo:
Add a github action
that pushes to docker hub, ssh in to the droplet and runs
     microk8s kubectl rollout restart deployment (name)
     
For example 

https://github.com/askasp/jaa_api_live/blob/main/.github/workflows/main.yml


## TODO
1. Make a persistent storage claim and volume
2. Add eventstore helm chart
3. Add Redis for read models (Need to switch to something else if we run out of memory) 

## How to set it up (for future reference)

### Installing

    sudo snap install microk8s --classic 
    microk8s enable dashboard dns storage


### Remote connection
On remote
    microk8s config > config        
    scp root@$SERVERIP:~/.kube/config ~/.kube/config
    
    sed -ie "s/127.0.0.1/$SERVERIP/g" ~/.kube/config
    sed -ie "s/127.0.0.1/$SERVERIP/g" ~/.kube/config
    ssh -i .ssh/aws_key -N -L localhost:16443:localhost:16443 root@167.99.218.91
    
Then use kubectl as normal

### Namespaces
We have one namespace for dev and one for production so 
we can run both in the same cluster

To set up run
            kubectl create -f  namespace-prod.json
            kubectl create -f  namespace-dev.json

see for more details
https://kubernetes.io/docs/tasks/administer-cluster/namespaces-walkthrough/


### Private docker hub registry
    docker login (on host)
    kubectl create secret generic regcred \
    --from-file=.dockerconfigjson=<path/to/.docker/config.json> \
    --type=kubernetes.io/dockerconfigjson
    
To container that are secret add 
    imagePullSecrets:
        -name: regred 
        
        
### Deployments ( the actual app)
    kubectl create -f abbo-deployment.yaml

### Certmanager & ingress
    kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.3.1/cert-manager.yaml
    kubectl create -f  production_issuer.yaml
    kubectl create -f  staging-issuer.yaml
    
    kubectl create -f dev-ingress.yaml

Always test with staging issuer in dev-ingress first
as letsencrypt bans you for 24h if you ask for a cert to many times


### Expose dashboard on internet
    kubectl create -f ingress-kubesystem.yaml


