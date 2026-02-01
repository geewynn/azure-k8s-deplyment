# GitOps with Flux

## Prerequisites

Register the Kubernetes Configuration provider:

```bash
az provider register --namespace Microsoft.KubernetesConfiguration
```

## SSH Deploy Key Setup

1. Generate a key pair:

```bash
ssh-keygen -t ed25519 -f ~/.ssh/gitops -N "" -C "n8n-gitops-deploy-key"
```

2. Add the public key to the gitops repo:

```bash
gh repo deploy-key add ~/.ssh/gitops.pub \
  --repo <your username>/gitops \
  --title "flux-deploy-key" \
  --allow-write
```

## Deploy

```bash
terraform init
terraform plan
terraform apply
```

## Verify

```bash
kubectl get pods -n flux-system
kubectl get gitrepositories -n flux-system
kubectl get kustomizations -n flux-system
```
