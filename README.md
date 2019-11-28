# geode-k8s-sandbox

Apache Geode on Kubernetes with rudimentary health checks, service discovery, and rollout capabilities

## Reflection

This was an excerise for me to understand how Kubernetes works and try to deploy Geode on it.

Progress
1. My first attempt was to create a Deployment for locators. It worked for a single locator, but with more than one locator they could not discover each other due to the service doing round-robin load balancing.
2. I tried using a single StatefulSet for both locators and servers. I designated the first pod as the locator and all the rest as servers. This had the advantage of guaranteeing the ordering for rollouts. However, when I started to do service discovery I found that there was no way to discover which pods were servers and which were locators.
3. Next, I separated locators and servers into different StatefulSets. This allowed me to create separate services for each one.
4. To implement service discovery for locators, I added an init script for the pods that queries for SRV records and uses the hostnames and ports to formulate the Geode startup comand.
5. I noticed that during rollouts, pods were being terminated/created before the previous pod was completely online. I added readiness and liveness checks using GFSH status command to prevent this. That command also has the benefit that during startup, the status does not become "online" until redundancy restore and disk recovery have completed. This does not completely solve the problem of safely terminating pods because there is still no way to delay termination of a pod while it recovers redundancy.

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

