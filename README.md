Requirements:
  - kind and kubectl already installed
  - cluster already created
 
<!-- kubectl installation -->
curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl

chmod +x ./kubectl

sudo mv ./kubectl /usr/local/bin/kubectl

kubectl version --client


<!-- kind installation -->
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.14.0/kind-linux-amd64

chmod +x ./kind

sudo mv ./kind /usr/local/bin/kind

### Create cluster
kind create cluster --config cluster.yaml

### List the clusters
kind get clusters

### List the nodes
kubectl get nodes
---------------------------------------------------------------------

## Day 1
Goal: Create pod using kubectl
Note: Perform the commands below inside day-1 folder

<!-- Step 1 - Create the manifest file -->
kubectl run nginx-giropops --image nginx --port 80 --dry-run=client -o yaml > pod.yaml
Note: If the manisfest file already exists you can skip this step.

Step 2 - Remove the following lines from manisfest
creationTimestamp: null
resources: {}
status: {}

Step 3 - Create the pod applying the manisfest file
kubectl apply -f pod.yaml

Step 4 - List the pods
kubectl get pods
Note: Check if the STATUS column is Running and READY column is 1/1

Step 5 - Execute the command below to see details about the pod and check the containers
kubectl describe pods nginx-giropops

Step 6 - Access the container
kubectl exec nginx-giropops -c nginx-giropops -it -- bash

Step 7 - Inside the container type the following command:
curl localhost

Step 8 - In this point, you will be able to see the Welcome Message from Nginx
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>

Step 9 - Delete the pod
kubectl delete -f pod.yaml
or
kubectl delete pods nginx-giropops
---------------------------------------------------------------------

Day 2
Goal: Create pod with two containers using namespace, resource limits/requests and volumes
Note: Perform the commands below inside day-2 folder

Step 1 - Create the namespace using the manifest file
kubectl apply -f namespace.yaml

Step 2 - List the namespaces
kubectl get namespaces

Step 3 - Create the pod using the manifest file
kubectl apply -f pod-resources-volumes.yaml

Step 4 - List the pod by namespace
kubectl get pods -n giropops-ns

Step 5 - Check the details using command describe
kubectl describe pods giropops-day2 -n giropops-ns

Step 6 - Access the containers
kubectl exec giropops-day2 -c giropops1 -it -n giropops-ns -- bash
kubectl exec giropops-day2 -c giropops2 -it -n giropops-ns -- bash

Step 7 - For the container giropops1 create the log file inside audit-nginx folder
cd audit-nginx 
echo "Test nginx log" > nginx.log

Step 8 - For the container giropops2 create the log file inside audit-ubuntu folder
cd audit-ubuntu 
echo "Test ubuntu log" > ubuntu.log

Step 9 - Check the node where the pod are running
kubectl get pods giropops-day2 -n giropops-ns -o wide

Step 10 - Check the pod uid
kubectl get pods giropops-day2 -n giropops-ns -o jsonpath='{.metadata.uid}'

Step 11 - List the nodes and access it using docker exec
docker container exec -it {containerUid} bash

Step 12 - Access the following directory based on pod uid
cd /var/lib/kubelet/pods/{podUid}/volumes/kubernetes.io~empty-dir

Step 13 - Check if the volumes were created and the files are not empty
giropops1-vol/nginx.log
giropops2-vol/ubuntu.log

Step 14 - Destroy the namespace and pod
kubectl delete -f namespace.yaml
-----------------------------------------------------------------------

Day 3
Goal: Create deployments using Recreate and RollingUpdate strategies
Note: Perform the commands below inside day-3 folder

# For recreate strategy
Step 1 - Create the deployment with recreation strategy using the manifest file
kubectl apply -f deployment-recreate-strategy.yaml

Step 2 - List the deployments
kubectl get deployments -l app=nginx-deployment

Step 3 - List the pods
kubectl get pods -l app=nginx-deployment

Step 4 - Open the manifest file and change the nginx image version(downgrade or upgrade)
vim deployment-recreate-strategy.yaml

Step 5 - Apply the deployment again
kubectl apply -f deployment-recreate-strategy.yaml

Step 6 - Check deployment status
kubectl rollout status deployment nginx-deployment

Step 7 - List the pods again
kubectl get pods -l app=nginx-deployment

Step 8 - List deployment details and check if container image was changed
kubectl describe deployment nginx-deployment

Step 9 - Delete the deployment
kubectl delete deployment nginx-deployment
or
kubectl delete -f deployment-recreate-strategy.yaml

Step 10 - Check if the deployment and pods were removed from cluster
kubectl get deployments -l app=nginx-deployment
kubectl get pods -l app=nginx-deployment

# For rollingUpdate strategy
Step 11 - Create the deployment with rollingUpdate strategy using the manifest file
kubectl apply -f deployment-rolling-update-strategy.yaml

Step 12 - List the deployments
kubectl get deployments -l app=nginx-deployment

Step 13 - List the pods
kubectl get pods -l app=nginx-deployment

Step 14 - Open the manifest file and change the nginx image version(downgrade or upgrade)
vim deployment-rolling-update-strategy.yaml

Step 15 - Apply the deployment again
kubectl apply -f deployment-rolling-update-strategy.yaml

Step 16 - Check deployment status
kubectl rollout status deployment nginx-deployment

Step 17 - List the pods again
kubectl get pods -l app=nginx-deployment

Step 18 - List deployment details and check if container image was changed
kubectl describe deployment nginx-deployment

Step 19 - Delete the deployment
kubectl delete deployment nginx-deployment
or
kubectl delete -f deployment-rolling-update-strategy.yaml

Step 20 - Check if the deployment and pods were removed from cluster
kubectl get deployments -l app=nginx-deployment
kubectl get pods -l app=nginx-deployment
