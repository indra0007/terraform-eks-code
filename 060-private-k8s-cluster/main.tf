data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
  version                = "~> 1.9"
}

module "eks" {
  source                    = "terraform-aws-modules/eks/aws"
  version                   = "17.1.0"
  cluster_version           = "1.18"
  cluster_name              = "eks-workshop"
  cluster_enabled_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  tags = local.cluster_tags
  map_roles = [
    {
      rolearn  = data.terraform_remote_state.cross_account_auth_account_admin.outputs.cross_account_auth_admin_role_arn
      username = data.terraform_remote_state.cross_account_auth_account_admin.outputs.cross_account_auth_admin_role_name
      groups   = ["system:masters"]
    },
    {
      rolearn  = data.terraform_remote_state.cross_account_auth_k8s_cluster_admin.outputs.iam_k8s_admin_role.arn
      username = data.terraform_remote_state.cross_account_auth_k8s_cluster_admin.outputs.iam_k8s_admin_role.name
      groups   = ["system:masters"]
    }
  ]
  cluster_endpoint_public_access = false
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access_cidrs = [ "0.0.0.0/0" ]
  cluster_endpoint_private_access_cidrs = [ "10.122.0.0/16" ]
  cluster_endpoint_private_access_sg = [ "sg-04e468842f3734bb4" ]
  cluster_create_endpoint_private_access_sg_rule = true
  cluster_security_group_id = data.terraform_remote_state.vpc.outputs.cluster-sg
  cluster_create_security_group = false
  subnets                = data.terraform_remote_state.vpc.outputs.private_subnet_ids
  vpc_id                 = data.terraform_remote_state.vpc.outputs.vpc_id
  worker_groups          = local.worker_groups
  worker_create_security_group = false
  worker_security_group_id = data.terraform_remote_state.vpc.outputs.allnodes-sg
  kubeconfig_output_path = "${path.module}/../../../kubeconfigs/"
  enable_irsa            = true
  manage_aws_auth        = true
}
