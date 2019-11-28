# geode-k8s-sandbox

Apache Geode on Kubernetes with rudimentary health checks, service discovery, and rollout capabilities

## How to Run

```bash
# Build docker image
docker build -t geode-k8s docker/

# Create local cluster
kind create cluster --config=kind-config.yaml

# Load docker image onto cluster
kind load docker-image geode-k8s:latest

# Create kubernetes objects
kubectl apply -f locator/locator-service.yaml
kubectl apply -f locator/locator-statefulset.yaml
kubectl apply -f server/server-service.yaml
kubectl apply -f server/server-statefulset.yaml

# Wait for all replicas to become ready
watch kubectl get statefulsets
# NAME            READY   AGE
# geode-locator   3/3     8m23s
# geode-server    3/3     8m6s

# Connect to GFSH interactively
kubectl exec -it geode-locator-0 -- /geode/bin/gfsh

# Or, execute a sequence of GFSH commands
kubectl exec -it geode-locator-0 -- /geode/bin/gfsh -e "connect" -e "list members"
# Member Count : 6
# 
#   Name    | Id
# --------- | ------------------------------------------------------------
# server-0  | 10.244.1.2(server-0:131)<v1>:41000
# locator-1 | 10.244.1.3(locator-1:60:locator)<ec><v2>:41000
# locator-2 | 10.244.1.4(locator-2:28:locator)<ec><v4>:41000
# locator-0 | 10.244.2.2(locator-0:16:locator)<ec><v0>:41000 [Coordinator]
# server-1  | 10.244.2.3(server-1:19)<v3>:41000
# server-2  | 10.244.2.4(server-2:19)<v5>:41000
```

