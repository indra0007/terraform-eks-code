output "worker_security_group_id" {
  value = module.eks.worker_security_group_id
}

output "irsa_provider_url" {
  value = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
}

output "oidc_id" {
  value = replace(module.eks.cluster_oidc_issuer_url, "https://oidc.eks.${local.env.region}.amazonaws.com/id/", "")
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}
