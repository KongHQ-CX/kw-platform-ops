# Konnect Automations Workshop - Platform Team Repository

## Local development prerequisites

- Docker
- kubectl (>= 1.27)
- helm (>= 3.12)
- kind (or k3d) for a local Kubernetes cluster
- act (optional) for local GitHub Actions testing

## Quickstart: local Kubernetes with kind

1. Create a cluster:
   - kind create cluster --name kw-dev
2. Export kubeconfig (kind sets this automatically). Verify access:
   - kubectl get nodes
3. When done:
   - kind delete cluster --name kw-dev

## Runner tooling

In workflows, reuse the composite action at `.github/actions/setup-k8s-tools` to install kubectl and helm with pinned versions:

- uses: ./.github/actions/setup-k8s-tools
  with:
  kubectl-version: v1.27.16
  helm-version: v3.12.3

## Notes

- The CI workflow will reuse scripts in ./scripts where possible.
- Chart values base lives in ./k8s/values.yaml and will be overlaid by the composite action.
