
# Set a variable to your server IP
SERVERIP=xxx.xxx.xxx.xxx

# Copy the ~/.kube/config from the Server to your machine
scp root@$SERVERIP:~/.kube/config ~/.kube/config
sed -ie "s/127.0.0.1/$SERVERIP/g" ~/.kube/config

