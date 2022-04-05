
locals {
  database_port = 5432
}

# DB Instance
resource "aws_db_instance" "modzy" {
  identifier = "${local.identifier_prefix}-db"
  multi_az = var.db_multi_az
  parameter_group_name = aws_db_parameter_group.modzy_postgres.name
  vpc_security_group_ids = [
    aws_security_group.db_access.id
  ]

  allocated_storage = var.db_volume_size_in_gb
  max_allocated_storage = var.db_volume_max_size_in_gb
  engine = "postgres"
  engine_version = var.db_engine_version
  instance_class = var.db_instance_type
  storage_type = var.db_storage_type

  storage_encrypted = true
  kms_key_id = aws_kms_key.rds.arn

  db_subnet_group_name = aws_db_subnet_group.modzy.name
  publicly_accessible = false
  port = local.database_port

  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]

  backup_retention_period = 30
  backup_window = "02:00-03:30"
  maintenance_window = "sun:04:00-sun:06:00"
  copy_tags_to_snapshot = true

  deletion_protection = !var.force_deletion_of_all_resources
  delete_automated_backups = var.force_deletion_of_all_resources
  skip_final_snapshot = var.force_deletion_of_all_resources
  final_snapshot_identifier = "${local.identifier_prefix}-final-snapshot"

  name = var.db_database_name
  username = var.db_username
  password = random_password.db.result
}

# DB Parameter Group
resource "aws_db_parameter_group" "modzy_postgres" {
  name = "${local.identifier_prefix}-modzy-parametergroup"
  family = var.db_engine_family
  parameter {
    name = "rds.force_ssl"
    value = "1"
  }
}

# DB Subnet Group
resource "aws_db_subnet_group" "modzy" {
  name = "${local.identifier_prefix}-rds-subnet-group"
  subnet_ids = local.db_subnets
}

# DB Security Group
resource "aws_security_group" "db_access" {
  name = "${local.identifier_prefix}-modzy-db-access"
  description = "Allows access to the Modzy RDS instance."
  vpc_id = var.vpc_id

  ingress {
    description = "Postgres traffic from application/model subnets."
    protocol = "tcp"
    from_port = local.database_port
    to_port = local.database_port
    cidr_blocks = concat(
      [for s in data.aws_subnet.platform_subnets : s.cidr_block],
      [for s in data.aws_subnet.model_subnets : s.cidr_block],
      [for s in data.aws_subnet.db_subnets : s.cidr_block],
      var.management_cidrs
    )
  }

  egress {
    description = "Postgres traffic to application/to subnets."
    protocol = "tcp"
    from_port = local.database_port
    to_port = local.database_port
    cidr_blocks = concat(
      [for s in data.aws_subnet.platform_subnets : s.cidr_block],
      [for s in data.aws_subnet.model_subnets : s.cidr_block],
      [for s in data.aws_subnet.db_subnets : s.cidr_block],
      var.management_cidrs
    )
  }
}
