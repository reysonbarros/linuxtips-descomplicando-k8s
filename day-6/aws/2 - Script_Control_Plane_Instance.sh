# Start the cluster on control plane machine instance
sudo kubeadm init --pod-network-cidr=10.10.0.0/16 --apiserver-advertise-address=172.30.2.128
# Note: Execute this command ONLY on control plane node instance(k8s-01). Do NOT execute this command inside other instances.
# Note2: Perform in the terminal the command(ip a) to get the IP address
# Note3: After execute this command the node STATUS is NotReady because is necessary to install the network plugin to enable pod's communication

# Configure access from kubelet to cluster
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Verify the admin.conf:
kubectl config view

# Execute the Script_Join_Workers_Instances.sh

# Install CNI Weave Net
kubectl apply -f https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml
# Note: Execute this command on k8s-01 machine instance(control plane)
# Note2: Check if node status is Ready using the command(kubectl get nodes)


# Create a secret in Kubernetes cluster with AWS key id and secret key
cat <<EOF | sudo tee secret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: aws-secret
  namespace: kube-system
stringData:
  key_id: "{AWS_KEY_ID}"
  access_key: "{AWS_SECRET_KEY}"
EOF
Note: Generate the AWS key and secret on Security Credentials(AWS)

  
# Apply the secret.yaml and check if it was created
kubectl apply -f secret.yaml  
kubectl get secrets -n kube-system

# Install AWS EBS CSI Driver
kubectl apply -k "github.com/kubernetes-sigs/aws-ebs-csi-driver/deploy/kubernetes/overlays/stable/?ref=master"

# Check  aws-ebs-csi-driver pods status in Kubernetes to make sure its got installed successfully
kubectl get pods -n kube-system | grep ebs

# Create storage class for EBS
cat <<EOF | sudo tee storageclass.yaml
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: ebs-storage
provisioner: ebs.csi.aws.com
volumeBindingMode: WaitForFirstConsumer
EOF

# Apply the storageclass.yaml file and check if it was created
kubectl apply -f storageclass.yaml
kubectl get storageclass

# Create the persistent volume claim
cat <<EOF | sudo tee pvc.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: ebs-claim
spec:
  accessModes:
  - ReadWriteOnce
  storageClassName: ebs-storage
  resources:
    requests:
      storage: 2Gi
EOF
# Apply the pvc.yaml file and check if it was created
kubectl apply -f pvc.yaml
kubectl get pvc

# Create the pod:
cat <<EOF | sudo tee pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: app
spec:
  containers:
  - name: app
    image: centos
    command: ["/bin/sh"]
    args: ["-c", "while true; do echo $(date -u) >> /data/out.txt; sleep 5; done"]
    volumeMounts:
    - name: persistent-storage
      mountPath: /data
  volumes:
  - name: persistent-storage
    persistentVolumeClaim:
      claimName: ebs-claim
EOF

# Apply the pod.yaml file and check if it was created
kubectl apply -f pod.yaml
kubectl get pods

# Verify PV and PVC which is created automatically with EBS
kubectl get pv
kubectl get pvc

# Get the volume id(VolumeHandle) property and verify same volume id will be there in AWS EBS with the created size
kubectl describe pv


# Access the container from pod
kubectl exec -it app -- bash 

# Check the file below
tail -f /data/out.txt    



