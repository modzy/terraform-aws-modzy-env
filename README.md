# Modzy Environment Terraform Module

This Terraform module will provision all the infrastructure necessary to run a
Modzy environment in AWS. 

## Usage

Create Terraform template file with content as below, insert the variables:

(Refer to the Modzy <a href="https://docs.modzy.com/docs/aws">Deployment Guide </a>  for full usage/configuration details)

```shell
module "modzy-env" {
  source  = "modzy/modzy-env/aws"
  version = "1.0.0"
  # insert (required) input variables here
}
```

## Inputs

| Name | Description | Type | Default | Required |
|:------|:-------------|:------|:---------|:----------|
| admin_email | The email address of the first Modzy user who will be created as a Platform Administrator | string | | yes |
| aws_region | The AWS Region that this deployment will be made in. | string | | yes |
| aws_profile | The AWS CLI profile to use to provide credentials to automate AWS resources. | string | | yes |
| installation_identifier | The installation identifier. This value will be used to tag prefix all resource names for easy identification. This identifier should be unique for the AWS account it is being deployed in. | string | | yes |
| fqdn | The fully-qualified domain name (FQDN) that will be used to access this installation of Modzy. | string | | yes |
| k8s_version | The version of Kubernetes to deploy. (Note: 1.21 is most recent version tested with) | string | 1.21 | | yes |
| management_cidrs | A list of CIDRs that are considered part of your management network. These CIDRs will automatically be added to various security groups to allow direct access to internal resources. It is _highly_ recommended that these only include private networks accessed via VPN or bastion host/jump box. | list(string) | | yes |
| admin_role_arn | The AWS IAM Role ARN that will be granted full access to the EKS cluster. | string | | yes |
| tags | A map of tags that will be applied to every AWS object that supports tags. NOTE: An additional "ModzyInstallation" tag will automatically be added who's value is the `installation_identifier` specified above. | map(string) | | no |
| vpc_id | The VPC ID to deploy resources into. | string | | yes |
| public_subnets | A list of the subnets (ids) that are considered "public" and can be accessed directly. These are used primarily to deploy AWS Load Balancers into. | list(string) | | yes |
| platform_subnets | A list of the subnets that should be used for the EKS nodes that will run Modzy's platform services. These subnets should not be directly accessible. | list(string) | | yes |
| model_subnets | A list of the subnets that should be used for the EKS nodes that will run Modzy models. This list can be the same as `platform_subnets` or it can be different if you want to exercise more/different control over the Network ACLs for model nodes. | list(string) | | yes |
| db_subnets | A list of the subnets that should be used for the RDS database. This list can be the same as `platform_subnets` or it can be different if you want to exercise more/different control over the Network ACLs for model nodes. | list(string) | | yes |
| worker_ami_id | The AMI ID to use for platform nodes. (Latest Kubernetes 1.21 CPU AMI Id is availabe in AWS SSM Parameter - /aws/service/eks/optimized-ami/1.21/amazon-linux-2/recommended/image_id) | string | | yes |
| ec2_keypair_name | The EC2 Keypair name to assign to all EKS nodes. | string | | yes |
| app_node_instance_type | Instance type for EKS nodes | string | m5.xlarge | yes |
| model_node_groups | A list of the additional node groups to attach to EKS for running models. These node groups will deploy into the subnets specified in `model_subnets` above. This list can be customized based on the demands of the models you plan to run.<p> **NOTE:** Terraform manages this as a list. To avoid unexpected downtime, set all the `asg_*` values to 0 for node groups you no longer wish to use. If you remove one of the items, it will cause every nodegroup defined after to get destroyed and re-deployed which would result in some significant downtime. Please pay extra attention to the actions listed by `terraform plan` when changing this variable. </p> <p> **NOTE:** The latest AWS AMI IDs for CPU and GPU nodes are available in the following SSM parameters: </p> <p> CPU - */aws/service/eks/optimized-ami/1.21/amazon-linux-2/recommended/image_id*</p> <p> GPU - */aws/service/eks/optimized-ami/1.21/amazon-linux-2-gpu/recommended/image_id*</p>| list(object) | | yes |
| cluster_autoscaler_namespace | Namespace for the kubernetes cluster autoscaler | string | kube-system | yes |
| cluster_autoscaler_serviceaccount_name | Name for the kubernetes cluster autoscaler service account | string | cluster-autoscaler | yes |
| db_instance_type | RDS database class | string | db.t3.large | yes |
| db_multi_az | High availability (multi-az) mode setting. Note: This should be set to *true* for a production environment  | bool | false | yes |
| db_database_name | Name for the Modzy database | string | modzy | yes |
| db_username | Username for the database user | string | modzyadmin | yes |
| db_volume_size_in_gb | Storage size (GB) for the Modzy database | number | 10 | yes |
| db_volume_max_size_in_gb | Maximum storage threshold (GB) for the Modzy database | number | 50 | yes |
| db_storage_type | Database storage type | string | gp2 | yes |
| db_engine_version | Database engine version | string | 12.7 | yes |
| db_engine_family | Database engine family | string | postgres12 | yes |
| smtp_port | SMTP Port | number | 587 | yes |
| modzy_namespace | Kubernetes namespace for the modzy deployment | string | modzy | yes |
| ingress_min_replicas | Minium number of ingress pod replicas | number | 2 | yes |
| ingress_max_replicas | Maximum number of ingress pod replicas | number | 3 | yes |
| ingress_visibility_public | Determines if an external load balancer is configured (set to false for internal load balancer) | bool | false | yes |
| ingress_source_cidrs_whitelist | Ingress source CIDRs whitelist | list(string) | ["0.0.0.0/0"] | yes |
| replicated_config_output_path | Filesystem location to write out the rendered Replicated config (defaults to the current directory) | string | ./ | yes |
| ecr_base | Modzy container repository | string | proxy.replicated.com/proxy/modzy/131723959220.dkr.ecr.us-east-1.amazonaws.com | yes |
| force_deletion_of_all_resources | Setting this to true will bypass the lifecycle settings to prevent destruction of persistent data resources like S3 buckets, etc. on environment decommission/destruction. USE AT YOUR OWN RISK! This will allow the resources to be permanently deleted | bool | false | yes |
## Sample Input

The following is a list of sample values for the input variables described above.

```terraform
  admin_email = "john.doe@acmecorp.com"

  aws_region = "us-east-1"

  aws_profile = "my-aws-profile"

  installation_identifier = "modzy-install-1"

  fqdn = "modzy.mydomain.com"

  k8s_version = "1.21"

  management_cidrs = [
    "10.x.x.x/x"
  ]

  admin_role_arn = "arn:aws:iam::0123456789:role/RoleName"

  tags = {
    "Customer" = "Acme Corp"
  }

  vpc_id = "vpc-0123456789abcde"

  public_subnets = [
    "subnet-0111111111111111a",
    "subnet-0111111111111111b",
    "subnet-0111111111111111c",
  ]

  platform_subnets = [
    "subnet-0222222222222222a",
    "subnet-0222222222222222b",
    "subnet-0222222222222222c"
  ]

  model_subnets = [
    "subnet-0222222222222222a",
    "subnet-0222222222222222b",
    "subnet-0222222222222222c"
  ]

  db_subnets = [
    "subnet-0333333333333333a",
    "subnet-0333333333333333b",
  ]

  worker_ami_id = "ami-workeramiid123"

  ec2_keypair_name = "modzy-nodes"

  model_node_groups = [
    {
      name = "small-cpu"
      ami_id = "ami-CPUamiid123"
      instance_type = "m5.large"
      asg_desired_capacity = 0
      asg_min_size = 0
      asg_max_size = 3
    },
    {
      name = "medium-cpu"
      ami_id = "ami-CPUamiid123"
      instance_type = "m5.xlarge"
      asg_desired_capacity = 0
      asg_min_size = 0
      asg_max_size = 3
    },
    {
      name = "large-cpu"
      ami_id = "ami-CPUamiid123"
      instance_type = "m5.2xlarge"
      asg_desired_capacity = 0
      asg_min_size = 0
      asg_max_size = 3
    },
    {
      name = "small-gpu"
      ami_id = "ami-GPUamiid123"
      instance_type = "g4dn.xlarge"
      asg_desired_capacity = 0
      asg_min_size = 0
      asg_max_size = 1
    },
    {
      name = "medium-gpu"
      ami_id = "ami-GPUamiid123"
      instance_type = "p2.xlarge"
      asg_desired_capacity = 0
      asg_min_size = 0
      asg_max_size = 1
    }
  ]

```
