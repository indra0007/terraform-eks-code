locals {
  azs = [
    "${local.env.region}${local.env.azs[0]}"
  ]

  cluster_tags = merge({
    "KubernetesCluster"                                         = "eks-workshop"
    "kubernetes.io/cluster/eks-workshop"     = "owned"
    "k8s.io/cluster-autoscaler/enabled"                       = "true"
    "k8s.io/cluster-autoscaler/eks-workshop" = "owned"
  }, local.env.common_tags)

  infra_tags = [
    {
      key                 = "k8s.io/cluster-autoscaler/node-template/label/service-layer/role"
      value               = "infra"
      propagate_at_launch = true
    }
  ]

  worker_tags = [
    {
      key                 = "k8s.io/cluster-autoscaler/node-template/label/service-layer/role"
      value               = "worker"
      propagate_at_launch = true
    }
  ]

  worker_groups = [
    {
      name          = "infra"
      tags          = local.infra_tags
      instance_type = "m5.large"

      autoscaling_enabled   = true
      kubelet_extra_args    = "--node-labels=service-layer/role=infra"
      protect_from_scale_in = false
      pre_userdata          = data.local_file.userdata.content
      asg_min_size          = 1
      asg_desired_capacity  = 1
      asg_max_size          = 6
      # asg_recreate_on_change = true
    },
    {
      name          = "worker"
      tags          = local.worker_tags
      instance_type = "m5.large"

      autoscaling_enabled   = true
      kubelet_extra_args    = "--node-labels=service-layer/role=worker"
      protect_from_scale_in = false
      pre_userdata          = data.local_file.userdata.content
      asg_min_size          = 1
      asg_desired_capacity  = 1
      asg_max_size          = 6
      # asg_recreate_on_change = true
    }
  ]
}
