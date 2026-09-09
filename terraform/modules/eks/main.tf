module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = var.cluster_name
  kubernetes_version = var.kubernetes_version

  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids

  # EKS API endpoint
  endpoint_public_access  = true
  endpoint_private_access = true

  # Give the Terraform caller admin access
  enable_cluster_creator_admin_permissions = true

  # EKS control-plane logging
  enabled_log_types = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]

  # EKS managed add-ons
  addons = {
    coredns = {}

    eks-pod-identity-agent = {
      before_compute = true
    }

    kube-proxy = {}

    vpc-cni = {
      before_compute = true
    }
  }

  # Managed worker nodes
  eks_managed_node_groups = {
    main = {
      name = "main"

      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = [var.node_instance_type]

      min_size     = var.node_min_size
      max_size     = var.node_max_size
      desired_size = var.node_desired_size

      capacity_type = "ON_DEMAND"

      disk_size = 30

      labels = {
        Environment = "dev"
        NodeGroup   = "main"
      }
    }
  }

  tags = var.tags
}