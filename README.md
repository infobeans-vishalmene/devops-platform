# EKS GitOps & Kubernetes Observability Platform

A complete DevOps/GitOps demonstration project that provisions an **Amazon EKS cluster using Terraform**, deploys a containerized application using **Helm and Argo CD**, stores container images in **GitHub Container Registry (GHCR)**, and provides Kubernetes observability using **Prometheus, Grafana and Alertmanager**.

The project demonstrates an end-to-end workflow from infrastructure provisioning to GitOps deployment and monitoring.

---

## Architecture

```text
                         ┌─────────────────────┐
                         │       GitHub        │
                         │                     │
                         │ App Source         │
                         │ Helm Configuration  │
                         └──────────┬──────────┘
                                    │
                                    │ Git
                                    ▼
                         ┌─────────────────────┐
                         │      Argo CD        │
                         │   GitOps Controller  │
                         └──────────┬──────────┘
                                    │
                                    │ Reconcile
                                    ▼
┌──────────────────────────────────────────────────────────────┐
│                         Amazon EKS                            │
│                                                              │
│   ┌──────────────────────────────────────────────────────┐   │
│   │                  Application                         │   │
│   │                                                      │   │
│   │              ┌─────────────────┐                     │   │
│   │              │    FastAPI      │                     │   │
│   │              │   Application   │                     │   │
│   │              └────────┬────────┘                     │   │
│   │                       │                              │   │
│   │                       ▼                              │   │
│   │                Kubernetes Service                   │   │
│   └──────────────────────────────────────────────────────┘   │
│                                                              │
│   ┌──────────────────────────────────────────────────────┐   │
│   │                  Monitoring                          │   │
│   │                                                      │   │
│   │  ServiceMonitors ──▶ Prometheus ──▶ Grafana          │   │
│   │                         │                            │   │
│   │                         └──────▶ Alertmanager        │   │
│   │                                                      │   │
│   └──────────────────────────────────────────────────────┘   │
└──────────────────────────────────────────────────────────────┘

Terraform
    │
    ▼
AWS VPC + EKS + Worker Nodes
```

---

## Technology Stack

| Area                   | Technology                |
| ---------------------- | ------------------------- |
| Cloud                  | AWS                       |
| Infrastructure as Code | Terraform                 |
| Kubernetes             | Amazon EKS                |
| Containerization       | Docker                    |
| Container Registry     | GitHub Container Registry |
| Application            | FastAPI                   |
| Kubernetes Packaging   | Helm                      |
| GitOps                 | Argo CD                   |
| Metrics                | Prometheus                |
| Visualization          | Grafana                   |
| Alerting               | Alertmanager              |
| Metrics Discovery      | ServiceMonitor            |

---

## Project Structure

```text
.
├── .github/
│   └── workflows/
│
├── app/
│   ├── src/
│   ├── tests/
│   ├── Dockerfile
│   └── requirements.txt
│
├── argocd/
│   └── application configuration
│
├── docs/
│
├── helm/
│   └── devops-platform/
│       ├── templates/
│       ├── Chart.yaml
│       └── values.yaml
│
├── kubernetes/
│   └── helm/
│
├── monitoring/
│
├── terraform/
│   ├── environments/
│   │   └── dev/
│   │
│   └── modules/
│       ├── eks/
│       └── vpc/
│
└── README.md
```

> `.terraform`, `.venv`, `.pytest_cache`, compiled files and other generated files should not be committed to Git.

---

# Prerequisites

Install:

* AWS CLI
* Terraform
* kubectl
* Helm
* Docker
* Git
* Argo CD CLI (optional)

Verify:

```bash
aws --version
terraform version
kubectl version --client
helm version
docker --version
git --version
argocd version --client
```

---

# 1. Configure AWS

Configure AWS credentials:

```bash
aws configure
```

Verify:

```bash
aws sts get-caller-identity
```

Set the AWS region:

```bash
aws configure set region <AWS_REGION>
```

Example:

```bash
aws configure set region ap-south-1
```

The AWS identity used must have sufficient permissions to create the required VPC and EKS resources.

---

# 2. Provision AWS Infrastructure

The Terraform configuration is located under:

```text
terraform/environments/dev/
```

Navigate there:

```bash
cd terraform/environments/dev
```

Initialize Terraform:

```bash
terraform init
```

Review the changes:

```bash
terraform plan
```

Apply:

```bash
terraform apply
```

Verify the EKS cluster:

```bash
aws eks list-clusters --region <AWS_REGION>
```

---

# 3. Configure kubectl

After the EKS cluster has been created:

```bash
aws eks update-kubeconfig \
  --region <AWS_REGION> \
  --name <EKS_CLUSTER_NAME>
```

Verify:

```bash
kubectl get nodes
```

Expected:

```text
NAME                                         STATUS   ROLES
ip-10-x-x-x.<region>.compute.internal       Ready    <none>
ip-10-x-x-x.<region>.compute.internal       Ready    <none>
```

Verify cluster connectivity:

```bash
kubectl cluster-info
```

---

# 4. Build the Application

Navigate to the application directory:

```bash
cd app
```

Build the Docker image:

```bash
docker build -t ghcr.io/<GITHUB_USERNAME>/<IMAGE_NAME>:<TAG> .
```

Example:

```bash
docker build -t ghcr.io/example-user/fastapi-app:1.0.0 .
```

Optionally test locally:

```bash
docker run --rm -p 8000:8000 \
  ghcr.io/<GITHUB_USERNAME>/<IMAGE_NAME>:<TAG>
```

The application can then be accessed at:

```text
http://localhost:8000
```

---

# 5. Push Image to GHCR

Authenticate with GitHub Container Registry:

```bash
docker login ghcr.io
```

Push the image:

```bash
docker push ghcr.io/<GITHUB_USERNAME>/<IMAGE_NAME>:<TAG>
```

Example:

```bash
docker push ghcr.io/example-user/fastapi-app:1.0.0
```

Use versioned image tags instead of relying on `latest`.

---

# 6. Install Argo CD

Create the namespace:

```bash
kubectl create namespace argocd
```

Install Argo CD:

```bash
kubectl apply \
  -n argocd \
  -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

Check the pods:

```bash
kubectl get pods -n argocd
```

Wait until the Argo CD components are running.

---

# 7. Access Argo CD

Port-forward the Argo CD server:

```bash
kubectl port-forward \
  svc/argocd-server \
  -n argocd \
  8080:443
```

Open:

```text
https://localhost:8080
```

Get the initial admin password:

```bash
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" |
  base64 --decode
```

Login:

```text
Username: admin
Password: <password returned above>
```

---

# 8. Deploy the Application with Argo CD

The Argo CD configuration is located under:

```text
argocd/
```

Apply the Argo CD Application:

```bash
kubectl apply -f argocd/application.yaml
```

Check:

```bash
kubectl get applications -n argocd
```

Or:

```bash
argocd app list
```

The application should eventually show:

```text
SYNC STATUS    HEALTH STATUS
Synced         Healthy
```

---

# 9. Verify the Application

Check application pods:

```bash
kubectl get pods -n <APPLICATION_NAMESPACE>
```

Check services:

```bash
kubectl get svc -n <APPLICATION_NAMESPACE>
```

Check deployments:

```bash
kubectl get deployments -n <APPLICATION_NAMESPACE>
```

The application pod should reach:

```text
Running
```

---

# 10. Install Kubernetes Monitoring

Create the monitoring namespace:

```bash
kubectl create namespace monitoring
```

Add the Prometheus Community repository:

```bash
helm repo add prometheus-community \
  https://prometheus-community.github.io/helm-charts
```

Update the repository:

```bash
helm repo update
```

Install kube-prometheus-stack:

```bash
helm upgrade --install monitoring \
  prometheus-community/kube-prometheus-stack \
  -n monitoring
```

Verify:

```bash
helm list -n monitoring
```

---

# 11. Verify Monitoring Components

Check monitoring pods:

```bash
kubectl get pods -n monitoring
```

You should see components including:

```text
monitoring-grafana
monitoring-kube-prometheus-operator
prometheus-monitoring-kube-prometheus-prometheus-0
alertmanager-monitoring-kube-prometheus-alertmanager-0
monitoring-kube-state-metrics
monitoring-prometheus-node-exporter-xxxxx
```

Check services:

```bash
kubectl get svc -n monitoring
```

---

# 12. Verify Prometheus

Check the Prometheus resource:

```bash
kubectl get prometheus -n monitoring
```

Check the Prometheus pod:

```bash
kubectl get pod \
  prometheus-monitoring-kube-prometheus-prometheus-0 \
  -n monitoring
```

Expected:

```text
READY   STATUS
2/2     Running
```

---

# 13. Check Prometheus Targets

Port-forward Prometheus:

```bash
kubectl port-forward \
  svc/monitoring-kube-prometheus-prometheus \
  -n monitoring \
  9090:9090
```

Open:

```text
http://localhost:9090
```

Navigate to:

```text
Status → Targets
```

Targets should show:

```text
UP
```

Typical targets include:

```text
apiserver
coredns
kubelet
kube-proxy
kube-state-metrics
node-exporter
prometheus
alertmanager
prometheus-operator
```

You can also query:

```text
http://localhost:9090/api/v1/query?query=up
```

A successful response contains:

```json
{
  "status": "success"
}
```

and healthy targets have:

```text
"value": ["...", "1"]
```

---

# 14. ServiceMonitor

The kube-prometheus-stack uses `ServiceMonitor` resources to discover Kubernetes services that expose metrics.

List ServiceMonitors:

```bash
kubectl get servicemonitors -A
```

For this installation:

```bash
kubectl get servicemonitors -A -l release=monitoring
```

Typical targets include:

```text
alertmanager
apiserver
coredns
kubelet
kube-state-metrics
node-exporter
operator
prometheus
```

The monitoring flow is:

```text
Kubernetes Service
        │
        ▼
   ServiceMonitor
        │
        ▼
Prometheus Operator
        │
        ▼
Prometheus
        │
        ▼
     Metrics
```

---

# 15. Access Grafana

Port-forward Grafana:

```bash
kubectl port-forward \
  svc/monitoring-grafana \
  -n monitoring \
  3000:80
```

Open:

```text
http://localhost:3000
```

Get the admin username:

```bash
kubectl get secret monitoring-grafana \
  -n monitoring \
  -o jsonpath="{.data.admin-user}" |
  base64 --decode
```

Get the password:

```bash
kubectl get secret monitoring-grafana \
  -n monitoring \
  -o jsonpath="{.data.admin-password}" |
  base64 --decode
```

Login using the returned credentials.

---

# 16. Grafana → Prometheus

The Prometheus datasource should point to:

```text
http://monitoring-kube-prometheus-prometheus.monitoring:9090/
```

The datasource should be configured as:

```text
Name:       Prometheus
Type:       Prometheus
Access:     Proxy
Default:    Yes
```

Verify connectivity from the Grafana pod:

```bash
kubectl exec -n monitoring \
  deploy/monitoring-grafana -- \
  sh -c "wget -qO- 'http://monitoring-kube-prometheus-prometheus.monitoring:9090/-/ready'"
```

Expected:

```text
Prometheus Server is Ready.
```

---

# 17. View Kubernetes Dashboards

In Grafana:

```text
Dashboards
    ↓
Browse
```

The kube-prometheus-stack provides Kubernetes dashboards such as:

```text
Kubernetes / Compute Resources / Cluster
Kubernetes / Compute Resources / Namespace
Kubernetes / Compute Resources / Pod
Kubernetes / Compute Resources / Node
Node Exporter
Kubelet
```

These dashboards provide visibility into:

* CPU usage
* Memory usage
* CPU requests and limits
* Memory requests and limits
* Pod information
* Node information
* Kubernetes resource utilization

---

# 18. Demonstrate GitOps

The main purpose of Argo CD is continuous reconciliation.

Make a change to the application or Helm configuration in Git.

```text
Developer
    │
    ▼
GitHub
    │
    │ Git change
    ▼
Argo CD
    │
    │ Reconcile
    ▼
EKS
    │
    ▼
Updated Application
```

Check the application:

```bash
argocd app get <APPLICATION_NAME>
```

Watch Kubernetes:

```bash
kubectl get pods \
  -n <APPLICATION_NAMESPACE> \
  -w
```

You can also watch the deployment:

```bash
kubectl get deployment \
  -n <APPLICATION_NAMESPACE> \
  -w
```

The key GitOps principle demonstrated here is:

```text
Git = Desired State

Argo CD:
Desired State
      ↓
Actual State
      ↓
Reconciliation
```

---

# 19. End-to-End Validation

Use the following commands to validate the complete platform.

### EKS

```bash
kubectl get nodes
```

Expected:

```text
Ready
```

### Application

```bash
kubectl get pods -n <APPLICATION_NAMESPACE>
```

Expected:

```text
Running
```

### Argo CD

```bash
kubectl get applications -n argocd
```

Expected:

```text
Synced
Healthy
```

### Prometheus

```bash
kubectl get prometheus -n monitoring
```

### Prometheus Targets

Open:

```text
http://localhost:9090/targets
```

Expected:

```text
Targets = UP
```

### Grafana

Open:

```text
http://localhost:3000
```

Expected:

```text
Prometheus datasource = Connected
Dashboards = Available
Metrics = Visible
```

---

# 20. Troubleshooting

### Check EKS nodes

```bash
kubectl get nodes
```

### Check all pods

```bash
kubectl get pods -A
```

### Check Argo CD

```bash
kubectl get applications -n argocd
```

### Check monitoring

```bash
kubectl get pods -n monitoring
```

### Check ServiceMonitors

```bash
kubectl get servicemonitors -A
```

### Check Prometheus targets

Open:

```text
http://localhost:9090/targets
```

### Check Prometheus logs

```bash
kubectl logs \
  prometheus-monitoring-kube-prometheus-prometheus-0 \
  -n monitoring
```

### Check Grafana logs

```bash
kubectl logs \
  deployment/monitoring-grafana \
  -n monitoring
```

---

# 21. Useful Commands

## Kubernetes

```bash
kubectl get nodes
kubectl get pods -A
kubectl get svc -A
kubectl get deployments -A
kubectl get statefulsets -A
```

## Argo CD

```bash
argocd app list
argocd app get <APPLICATION_NAME>
argocd app sync <APPLICATION_NAME>
```

## Helm

```bash
helm list -A
helm list -n monitoring
helm status monitoring -n monitoring
```

## Monitoring

```bash
kubectl get prometheus -n monitoring
kubectl get servicemonitors -A
kubectl get pods -n monitoring
kubectl get svc -n monitoring
```

---

# 22. Cleanup

Destroy the Terraform infrastructure when the demonstration is complete:

```bash
cd terraform/environments/dev
terraform destroy
```

If Argo CD or monitoring was installed separately and the cluster is being reused, they can be removed independently.

---

# 23. What This Project Demonstrates

This project demonstrates the following DevOps concepts in one environment:

```text
Infrastructure as Code
        │
        ▼
     Terraform
        │
        ▼
       AWS
        │
        ▼
       EKS
        │
        ▼
   Kubernetes
        │
        ├───────────────┐
        │               │
        ▼               ▼
    Argo CD         Monitoring
        │               │
        ▼               ├── Prometheus
      Helm              ├── Grafana
        │               └── Alertmanager
        ▼
  Application
        │
        ▼
      GHCR
```

The complete lifecycle is:

```text
Terraform
    ↓
AWS VPC + EKS
    ↓
Kubernetes
    ↓
Argo CD
    ↓
Helm
    ↓
Application
    ↓
Prometheus
    ↓
Grafana
    ↓
Observability
```

---

# 24. Final Demo Checklist

```text
[ ] AWS credentials configured
[ ] Terraform initialized
[ ] VPC created
[ ] EKS cluster created
[ ] Worker nodes Ready
[ ] Application image built
[ ] Image pushed to GHCR
[ ] Argo CD installed
[ ] Argo CD Application created
[ ] Application Synced
[ ] Application Healthy
[ ] Application pod Running
[ ] kube-prometheus-stack installed
[ ] Prometheus Running
[ ] Grafana Running
[ ] Alertmanager Running
[ ] ServiceMonitors discovered
[ ] Prometheus targets UP
[ ] Prometheus query working
[ ] Grafana datasource connected
[ ] Kubernetes dashboards visible
[ ] CPU/Memory metrics visible
[ ] Git change demonstrated through Argo CD
[ ] Updated application state observed in EKS
```

---

## Project Goal

The goal of this project is to provide a practical demonstration of a modern Kubernetes DevOps workflow:

> **Terraform provisions the AWS infrastructure, GitHub stores the application and desired configuration, GHCR stores container images, Helm packages the application, Argo CD continuously reconciles Kubernetes with Git, and Prometheus, Grafana and Alertmanager provide Kubernetes observability.**

This makes the repository useful as a **learning project, portfolio demonstration, and reference implementation for EKS, GitOps and Kubernetes monitoring**.
