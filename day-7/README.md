# Apply the Statefulset manifest
kubectl apply -f nginx-statefulset.yaml

# List the pods
kubectl get pods

# Delete one pod
kubectl delete pod nginx-2
Note: When the pod was delete the statefulset controller creates the pod again

# Scale pods
kubectl scale statefulset nginx --replicas 7

# List the pods again and check the number of replicas
kubectl get pods

# Apply the service ClusterIP
kubectl apply -f nginx-clusterip-svc.yaml

# List the services
kubectl get svc

# Update all index.html(nginx) file from all pod's containers
kubectl exec -it nginx-0 -c nginx -- bash
echo "Pod 0" > /usr/share/nginx/html/index.html
ctrl + d

kubectl exec -it nginx-1 -c nginx -- bash
echo "Pod 1" > /usr/share/nginx/html/index.html
ctrl + d

kubectl exec -it nginx-2 -c nginx -- bash
echo "Pod 2" > /usr/share/nginx/html/index.html
ctrl + d

kubectl exec -it nginx-3 -c nginx -- bash
echo "Pod 3" > /usr/share/nginx/html/index.html
ctrl + d

kubectl exec -it nginx-4 -c nginx -- bash
echo "Pod 4" > /usr/share/nginx/html/index.html
ctrl + d

kubectl exec -it nginx-5 -c nginx -- bash
echo "Pod 5" > /usr/share/nginx/html/index.html
ctrl + d

kubectl exec -it nginx-6 -c nginx -- bash
echo "Pod 6" > /usr/share/nginx/html/index.html
ctrl + d

# Execute the busybox for debugging
kubectl run -it --rm debug --image busybox --restart Never -- sh


# Execute the command below inside busybox container
wget -O- CLUSTER-IP
Note: Check if nginx's welcome message shows up
Note2: Perform the same command above many times and check if the responses change.

# Expose service using another service(for troubleshooting)
kubectl expose service nginx --name nginx-debug --type NodePort

# Get services and save the value from column PORT(S)
kubectl get svc
ex: 80:30769/TCP,27017:32319/TCP

# Get the nodes from cluster and save the value from column INTERNAL-IP
kubectl get nodes -o wide
ex: 172.18.0.5

# Execute the command below from local machine and validate if nginx's welcome message shows up
curl 172.18.0.5:30769
Note: Test this command for each node IP

# Apply the external name service httpbin
kubectl apply -f httpbin-externalname-svc.yaml

# List the service
kubectl get svc

# Execute the busybox for debugging
kubectl run -it --rm debug --image busybox --restart Never -- sh
wget -O- httpbin-service


