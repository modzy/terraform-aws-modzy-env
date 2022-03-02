terraform {
  required_version = ">= 0.15.4"
  required_providers {
    postgresql = {
      source = "cyrilgdn/postgresql"
      version = "1.13.0"
    }
    htpasswd = {
      source = "loafoe/htpasswd"
      version = "0.9.0"
    }

    aws = {
      version = "3.71.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
  profile = var.aws_profile

  default_tags {
    tags = local.tags
  }
}

provider "kubernetes" {
  host = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token = data.aws_eks_cluster_auth.cluster.token
}

provider "helm" {
  kubernetes {
    host = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
    token = data.aws_eks_cluster_auth.cluster.token
  }
}

provider "postgresql" {
  scheme = "awspostgres"
  host = aws_db_instance.modzy.address
  port = aws_db_instance.modzy.port
  database = aws_db_instance.modzy.name
  username = aws_db_instance.modzy.username
  password = aws_db_instance.modzy.password
  superuser = false
}

data "aws_availability_zones" "available" {}

data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

data "aws_region" "current" {}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

data "aws_vpc" "modzy" {
  id = var.vpc_id
}

data "aws_subnet" "platform_subnets" {
  for_each = toset(local.platform_subnets)
  id = each.value
}

data "aws_subnet" "model_subnets" {
  for_each = toset(local.model_subnets)
  id = each.value
}

data "aws_subnet" "db_subnets" {
  for_each = toset(local.db_subnets)
  id = each.value
}