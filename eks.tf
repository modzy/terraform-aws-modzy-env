module "eks" {
  source = "git::https://github.com/modzy/terraform-aws-modzy-eks.git?ref=v1.0.0"

  aws_region = var.aws_region
  aws_profile = var.aws_profile

  cluster_name = local.identifier_prefix
  k8s_version = var.k8s_version

  management_cidrs = var.management_cidrs
  admin_role_arn = var.admin_role_arn

  tags = local.tags

  vpc_id = local.vpc_id

  subnets = distinct(concat(local.public_subnets))

  ec2_keypair_name = var.ec2_keypair_name

  node_groups = concat(
    // App servers. Deploy a separate ASG in each AZ to protect against pods
    // getting rescheduled on pods in a different AZ than their PVs
    [for index, subnet in local.platform_subnets :
      {
        name = "modzy-platform-${data.aws_subnet.platform_subnets[subnet].availability_zone_id}"
        ami_id = var.worker_ami_id
        instance_type = var.app_node_instance_type
        subnets = [subnet]
        asg_desired_capacity = 1
        asg_max_size = 3
        asg_min_size = 1
        kubelet_extra_args = format(
          "--node-labels %s",
          join(",", [
            "modzy.com/node-type=platform",
            "modzy.com/nodegroup-name=modzy-platform-${data.aws_subnet.platform_subnets[subnet].availability_zone_id}"
          ])
        )
        tags = [
          {
            key = "ModzyNodeType"
            value = "Platform"
            propagate_at_launch = "true"
          },
          {
            key = "k8s.io/cluster-autoscaler/node-template/label/modzy.com/node-type"
            value = "platform"
            propagate_at_launch = "true"
          },
          {
            key = "k8s.io/cluster-autoscaler/node-template/label/modzy.com/nodegroup-name"
            value = "modzy-platform-${data.aws_subnet.platform_subnets[subnet].availability_zone_id}"
            propagate_at_launch = "true"
          }
        ]
      }
    ],
    // Add in any model node groups specified in configuration.
    [for index, node_group in var.model_node_groups :
      merge(node_group, {
        subnets = local.model_subnets
        kubelet_extra_args = format(
          "--node-labels %s --register-with-taints %s",
          join(",", [
            "modzy.com/node-type=inference",
            "modzy.com/nodegroup-name=modzy-inference-${node_group["name"]}"
          ]),
          join(",", compact([
            "modzy.com/inference-node=true:NoSchedule",
            length(regexall("^(p2|p3|p4|g3|g4)", node_group["instance_type"])) > 0 ? "nvidia.com/gpu=true:NoSchedule" : ""
          ]))
        )
        tags = [
          {
            key = "ModzyNodeType"
            value = "Inference"
            propagate_at_launch = "true"
          },
          {
            key = "k8s.io/cluster-autoscaler/node-template/label/modzy.com/node-type"
            value = "inference"
            propagate_at_launch = "true"
          },
          {
            key = "k8s.io/cluster-autoscaler/node-template/label/modzy.com/nodegroup-name"
            value = "modzy-inference-${node_group["name"]}"
            propagate_at_launch = "true"
          },
          {
            key = "k8s.io/cluster-autoscaler/node-template/taint/modzy.com/inference-node"
            value = "true:NoSchedule"
            propagate_at_launch = "true"
          }
        ]
      })
    ]
  )
}
