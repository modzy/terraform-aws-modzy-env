variable "admin_email" {
  description = "The email address of the first Modzy user who will be created as a Platform Administrator."
  type = string
}

variable "aws_region" {
  description = "The AWS Region that this deployment will be made in."
  type = string
}

variable "aws_profile" {
  description = "The AWS CLI profile to use to provide credentials to automate AWS resources."
  type = string
  default = "default"
}

variable "installation_identifier" {
  description = "The installation identifier. This value will be used to prefix all resource names for easy identification. This identifier should be unique for the AWS account it is being deployed in."
  type = string
}

variable "fqdn" {
  type = string
  description = "The fully-qualified domain name for this Modzy installation. (e.g. modzy.example.com)"
}

variable "k8s_version" {
  description = "The version of Kubernetes to deploy. (Note: 1.21 is most recent version tested with)"
  type = string
  default = "1.21"
}

variable "management_cidrs" {
  description = "A list of CIDRs that are considered part of your management network. These CIDRs will automatically be added to various security groups to allow direct access to internal resources. It is _highly_ recommended that these only include private networks accessed via VPN or bastion host/jump box."
  type = list(string)
}

variable "tags" {
  description = "A map of tags that will be applied to every AWS object that supports tags. NOTE: An additional 'ModzyInstallation' tag will automatically be added who's value is the 'installation_identifier' specified above."
  type = map(string)
}

variable "vpc_id" {
  description = "The VPC ID to deploy resources into."
  type = string
}

variable "public_subnets" {
  description = "A list of the subnets (ids) that are considered 'public' and can be accessed directly. These are used primarily to deploy AWS Load Balancers into."
  type = list(string)
}

variable "platform_subnets" {
  description = "A list of the subnets that should be used for the EKS nodes that will run Modzy's platform services. These subnets should not be directly accessible."
  type = list(string)
}

variable "model_subnets" {
  description = "A list of the subnets that should be used for the EKS nodes that will run Modzy models. This list can be the same as 'platform_subnets' or it can be different if you want to exercise more/different control over the Network ACLs for model nodes."
  type = list(string)
}

variable "db_subnets" {
  description = "A list of the subnets that should be used for the RDS database. This list can be the same as 'platform_subnets' or it can be different if you want to exercise more/different control over the Network ACLs for model nodes."
  type = list(string)
}

variable "admin_role_arn" {
  description = "The AWS IAM Role ARN that will be granted full access to the EKS cluster."
  type = string
}

variable "worker_ami_id" {
  description = "The AMI ID to use for platform nodes."
  type = string
}

variable "ec2_keypair_name" {
  description = "The EC2 Keypair name to assign to all EKS nodes."
  type = string
}

variable "app_node_instance_type" {
  description = "Instance type for EKS nodes"
  type = string
  default = "m5.xlarge"
}

variable "model_node_groups" {
  description = "Additional EKS node groups dedicated to running models."
  type = list(object({
    name = string
    ami_id = string
    instance_type = string
    asg_desired_capacity = number
    asg_min_size = number
    asg_max_size = number
    //    subnets = list(string)
    //    node_labels = list(string)
    //    node_taints = list(string)
  }))
  default = []
}

variable "cluster_autoscaler_namespace" {
  description = "Namespace for the kubernetes cluster autoscaler"
  type = string
  default = "kube-system"
}
variable "cluster_autoscaler_serviceaccount_name" {
  type = string
  default = "cluster-autoscaler"
}

variable "db_instance_type" {
  description = "RDS database class"
  type = string
  default = "db.t3.large"
}

variable "db_multi_az" {
  description = "High availability (multi-az) mode setting. Note: This should be set to 'true' for a production environment"
  type = bool
  default = false
}

variable "db_database_name" {
  description = "Name for the Modzy database"
  type = string
  default = "modzy"
}

variable "db_username" {
  description = "Username for the database user"
  type = string
  default = "modzyadmin"
}

variable "db_volume_size_in_gb" {
  description = "Storage size (GB) for the Modzy database"
  type = number
  default = 10
}

variable "db_volume_max_size_in_gb" {
  description = "Maximum storage threshold (GB) for the Modzy database"
  type = number
  default = 50
}

variable "db_storage_type" {
  description = "Database storage type"
  type = string
  default = "gp2"
}

variable "db_engine_version" {
  description = "Database engine version"
  type = string
  default = "12.7"
}

variable "db_engine_family" {
  description = "Databae engine family"
  type = string
  default = "postgres12"
}

variable "smtp_port" {
  description = "SMTP Port"
  type = number
  default = 587
}

variable "modzy_namespace" {
  description = "Kubernetes namespace for the modzy deployment"
  type = string
  default = "modzy"
}

variable "ingress_min_replicas" {
  description = "Minium number of ingress pod replicas"
  type = number
  default = 2
}

variable "ingress_max_replicas" {
  description = "Maximum number of ingress pod replicas"
  type = number
  default = 3
}

variable "ingress_visibility_public" {
  description = "Determines if an external load balancer is configured (set to false for internal load balancer)"
  type = bool
  default = false
}

variable "ingress_source_cidrs_whitelist" {
  description = "Ingress source CIDRs whitelist"
  type = list(string)
  default = ["0.0.0.0/0"]
}

variable "replicated_config_output_path" {
  description = "Filesystem location to write out the rendered Replicated config (defaults to the current directory)"
  type = string
  default = "./"
}

variable "ecr_base" {
  description = "Modzy container repository"
  type = string
  default = "proxy.replicated.com/proxy/modzy/131723959220.dkr.ecr.us-east-1.amazonaws.com"
}

variable "force_deletion_of_all_resources" {
  type = bool
  default = false
  description = "Setting this to true will bypass the lifecycle settings to prevent destruction of persistent data resources like S3 buckets, etc. on environment decommission/destruction. USE AT YOUR OWN RISK! This will allow the resources to be permanently deleted."
}
