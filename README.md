# Homelab GitOps

## Nix Shell

Generate kubeconfig when running minikube
```sh
kubectl config view --flatten --minify > kubeconfig-docker
```

Update kubeconfig with `minikube ip`
```sh
sed -i 's|https://127.0.0.1:[0-9]*|https://KUBE_CLUSTER_IP:8443|g' kubeconfig-docker
```

Create a docker volume to store all nix packages (this will make startup faster afters the 1st one)

```sh
docker volume create nix-store
```

Run the nix shell using docker
```sh
docker run -it --rm \
    --network=host \
    -v $(pwd):/workspace \
    -v $(pwd)/kubeconfig-docker:/root/.kube/config:ro \
    -v nix-store:/nix \
    -w /workspace \
    nixos/nix \
    nix-shell
```
