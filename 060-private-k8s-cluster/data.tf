data "terraform_remote_state" "cross_account_auth_account_admin" {
  backend = "s3"

  config = {
    bucket = local.env.backend_bucket_name
    key    = "005-iam/terraform.tfstate"
    region = local.env.region
  }
}

data "terraform_remote_state" "cross_account_auth_k8s_cluster_admin" {
  backend = "s3"

  config = {
    bucket = local.env.backend_bucket_name
    key    = "010-iam/terraform.tfstate"
    region = local.env.region
  }

  workspace = terraform.workspace
}

data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket = local.env.backend_bucket_name
    key    = "030-private-vpc/terraform.tfstate"
    region = local.env.region
  }

  workspace = terraform.workspace
}

data "local_file" "userdata" {
  filename = "${path.module}/../../global/data/userdata.sh"
}
