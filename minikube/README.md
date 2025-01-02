# Initial Minikube
## Basic 1:
```bash
minikube start \
  --apiserver-ips=10.40.9.11\
  --host-only-cidr='192.168.59.1/24 \
  --service-cluster-ip-range='10.96.0.0/12\
  --listen-address=0.0.0.0 \
  --kubernetes-version='' \
  --dns-domain=cluster.local \
  --ha=false \
  --nodes=1 \
  --cni=calico \
  --cpus=max \
  --memory=max \
  --insecure-registry=[] \
  --force=true
```

## Basic 2:
```bash
minikube start \
  --apiserver-ips=10.40.9.12\
  --host-only-cidr='192.168.59.1/24 \
  --service-cluster-ip-range='10.96.0.0/12\
  --listen-address=0.0.0.0 \
  --kubernetes-version='' \
  --dns-domain=cluster.local \
  --ha=false \
  --nodes=5 \
  --cni=flannel \
  --cpus=max \
  --memory=max \
  --force=true
```
# Expose Service
## Iptable Forward Port
```bash
iptables -t nat -A PREROUTING -p tcp --dport 443  -j DNAT --to-destination 192.168.49.100:443
iptables -t nat -A PREROUTING -p tcp --dport 80  -j DNAT --to-destination 192.168.49.100:443
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -j ACCEPT
```
Save iptable:
```bash
apt-get install iptables-persistent
netfilter-persistent save
```