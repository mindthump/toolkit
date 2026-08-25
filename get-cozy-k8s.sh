# Kubernetes
kubectl cp provision.sh mypod:/tmp/ -c mycontainer
kubectl cp tmux.conf mypod:/tmp/ -c mycontainer
kubectl exec -it mypod -c mycontainer -- bash /tmp/provision.sh
