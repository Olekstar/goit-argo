module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  vpc_id                   = data.terraform_remote_state.vpc.outputs.vpc_id
  subnet_ids               = data.terraform_remote_state.vpc.outputs.private_subnet_ids
  control_plane_subnet_ids = data.terraform_remote_state.vpc.outputs.private_subnet_ids

  cluster_endpoint_public_access           = true
  enable_cluster_creator_admin_permissions = true

  cluster_addons = {
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {}
  }

  eks_managed_node_group_defaults = {
    instance_types = ["t3.medium"]
  }

  eks_managed_node_groups = {
    cpu = {
      name         = "cpu-nodes"
      min_size     = 1
      max_size     = 2
      desired_size = 1
      labels = {
        workload = "cpu"
      }
    }
    gpu = {
      name         = "gpu-nodes"
      min_size     = 0
      max_size     = 1
      desired_size = 0
      instance_types = ["g4dn.xlarge"]
      labels = {
        workload = "gpu"
      }
      taints = [{
        key    = "nvidia.com/gpu"
        value  = "present"
        effect = "NO_SCHEDULE"
      }]
    }
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}
