# Execute the command below in workers instances that need to access the cluster:
kubeadm join 172.30.2.128:6443 --token nyo492.ag0ukapldhjii3df \
        --discovery-token-ca-cert-hash sha256:acc7de5a6a0f1ede55bac56fd0f8a30f7132b70fa586e675086bf2008ddd037a
