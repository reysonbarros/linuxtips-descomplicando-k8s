# 1 - Create 3 EC2 instances using the following minimum requirements:
#  2GB memory
#  2 CPUs
#  Linux distribution. Recomendation is Ubuntu 22.04
# Note: Use the t2.medium instance type

# 2 - Rename each instance created before using the AWS Console, for example:
# k8s-1
# k8s-2
# k8s-3

# 3 - Open these ports in the Security Groups:
#  22(SSH): SSH Access
#  6443(TCP): K8S API Server
#  10250-10255(TCP): K8S kubelet agent
#  30000-32767(TCP): K8S NodePort(serviços acessíveis fora do cluster)
#  2379-2380(TCP): K8S etcd
#  6783(TCP): Weave Net Control Port
#  6783-6784(UDP): Weave Net Data Port
 

# 4 - Access the instances using the ssh, for example:
# ssh -i "key-pair.pem" ubuntu@ec2-ip1.amazonaws.com
# ssh -i "key-pair.pem" ubuntu@ec2-ip2.amazonaws.com
# ssh -i "key-pair.pem" ubuntu@ec2-ip3.amazonaws.com
Note: Execute the command in the pem(key pair) file
chmod 400 *.pem

# 5 - Rename the hostnames foreach instance using the Linux terminal, for example:
sudo su -
hostnamectl hostname k8s-01
bash
# Note: Reproduce these steps for other instances

# 6 - Disable swap:
sudo swapoff -a
# Note: K8S does not work well using swap enabled and this is turned off by default on EC2 EBS-backed instances.

# 7 - If swap is not active, it doesn't show anything when execute this command below:
swapon --show

# 8 - Load kernel modules:
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# 9 - Configure and apply parameters from system:
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sudo sysctl --system

# 10 - Installing K8S packages:
sudo apt-get update && sudo apt-get install -y apt-transport-https curl

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl

sudo apt-mark hold kubelet kubeadm kubectl

# 11 - Installing containerd:
sudo apt-get update && sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update && sudo apt-get install -y containerd.io

# 12 - Configuring containerd to enable Cgroup:
sudo containerd config default | sudo tee /etc/containerd/config.toml

sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml

sudo systemctl restart containerd
sudo systemctl status containerd

# 13 - Enable kubelet service to auto start with the system:
sudo systemctl enable --now kubelet
# Note: Execute the command(systemctl list-units --type=service) to verify the services that initializes with the system

# 14 - Start the cluster on k8s-01 machine instance:
sudo kubeadm init --pod-network-cidr=10.10.0.0/16 --apiserver-advertise-address=172.30.2.122
# Note: Execute this command ONLY on control plane node instance(k8s-01). Do NOT execute this command inside other instances.
# Note2: Perform in the terminal the command(ip a) to get the IP address
# Note3: Execute the steps(14,15 and 16) on k8s-01 machine instance(control plane)


# 15 - Configure access from kubelet to cluster:
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# 16 - Verify the admin.conf:
kubectl config view

# 17 - Execute the command below in nodes instances(k8s-02 and k8s-03) that need to access the cluster:
kubeadm join 172.30.2.122:6443 --token zcsfwo.orgv18l2k8dfbz2d \
        --discovery-token-ca-cert-hash sha256:71c9910892548179dce8538dc9a621f5e5e0d4c3bfb8dcee2f7a98bf07ebde59
Note: After execute this command the node STATUS is NotReady because is necessary to install the network plugin to enable pod's communication

# 18 - Install CNI Weave Net:
kubectl apply -f https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml
# Note: Execute this command on k8s-01 machine instance(control plane)
# Note2: Check if node status is Ready using the command(kubectl get nodes)

# 19 - Execute the deployment:
kubectl create deployment nginx --image=nginx --replicas 3

# 20 - Check if the pod status:
kubectl get pods
