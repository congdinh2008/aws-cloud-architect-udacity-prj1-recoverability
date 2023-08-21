terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
  required_version = ">= 0.12"
}

provider "aws" {
  region = local.region1
}

provider "aws" {
  alias  = "region2"
  region = local.region2
}

data "aws_caller_identity" "current" {}

data "aws_availability_zones" "available" {}

data "http" "workstation-external-ip" {
  url = "http://ipv4.icanhazip.com"
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

}

locals {
  name                      = "udacitypr1"
  workstation-external-cidr = "${chomp(data.http.workstation-external-ip.response_body)}/32"
  rds_name                  = var.rds_name
  region1                   = var.region1
  region2                   = var.region2

  vpc_active_cidr_block  = var.vpc_active_cidr_block
  vpc_standby_cidr_block = var.vpc_standby_cidr_block
  azs                    = slice(data.aws_availability_zones.available.names, 0, 3)

  active_UDARR_Database    = "sg-0250dba85def2e27f"
  active_UDARR-Application = "sg-0f29759da6818536c"

  standby_UDARR_Database    = "sg-0d2b5337ed4d2aec5"
  standby_UDARR-Application = "sg-083cce6e39b13f458"

  rds_subnet_group_name = "${local.rds_name}-subnet-group"

  engine                = "mysql"
  engine_version        = "8.0"
  family                = "mysql8.0" # DB parameter group
  major_engine_version  = "8.0"      # DB option group
  instance_class        = "t3.micro"
  allocated_storage     = 20
  max_allocated_storage = 100
  port                  = 3306

  ec2_name = var.ec2_name

  bucket_name = var.s3_name

  tags = {
    Name       = local.name
    Example    = local.name
    Repository = "https://github.com/terraform-aws-modules/terraform-aws-rds"
  }
}

# ################################################################################
# # Create subnet and security groups for RDS
# ################################################################################

resource "aws_db_subnet_group" "active" {
  name       = "${local.rds_subnet_group_name}-active"
  subnet_ids = var.active_private_subnets
  tags       = local.tags
}

resource "aws_db_subnet_group" "standby" {
  name       = "${local.rds_subnet_group_name}-standby"
  provider   = aws.region2
  subnet_ids = var.standby_private_subnets
  tags       = local.tags
}

# ################################################################################
# # Master DB
# ################################################################################

# module "rds_active" {
#   source = "terraform-aws-modules/rds/aws"

#   identifier = "${local.rds_name}-active"

#   engine               = local.engine
#   engine_version       = local.engine_version
#   family               = local.family
#   major_engine_version = local.major_engine_version
#   instance_class       = local.instance_class

#   allocated_storage     = local.allocated_storage
#   max_allocated_storage = local.max_allocated_storage

#   db_name  = "udacity"
#   username = "udacity"
#   password = "Udacity^1234"
#   port     = local.port

#   multi_az               = true
#   db_subnet_group_name   = aws_db_subnet_group.active.name
#   vpc_security_group_ids = [local.active_UDARR_Database]

#   maintenance_window              = "Mon:00:00-Mon:03:00"
#   backup_window                   = "03:00-06:00"
#   enabled_cloudwatch_logs_exports = ["general"]

#   # Backups are required in order to create a replica
#   backup_retention_period = 1
#   skip_final_snapshot     = true
#   deletion_protection     = false

#   tags = local.tags
# }

# ################################################################################
# # Replica DB
# ################################################################################

# module "rds_standby" {
#   source = "terraform-aws-modules/rds/aws"

#   providers = {
#     aws = aws.region2
#   }

#   identifier = "${local.rds_name}-standby"

#   # Source database. For cross-region use db_instance_arn
#   replicate_source_db = module.rds_active.db_instance_identifier

#   engine               = local.engine
#   engine_version       = local.engine_version
#   family               = local.family
#   major_engine_version = local.major_engine_version
#   instance_class       = local.instance_class

#   allocated_storage     = local.allocated_storage
#   max_allocated_storage = local.max_allocated_storage

#   password = "Udacity^1234"
#   port     = local.port

#   # Not supported with replicas
#   manage_master_user_password = false

#   multi_az               = false
#   db_subnet_group_name   = aws_db_subnet_group.standby.name
#   vpc_security_group_ids = [local.standby_UDARR_Database]

#   maintenance_window              = "Tue:00:00-Tue:03:00"
#   backup_window                   = "03:00-06:00"
#   enabled_cloudwatch_logs_exports = ["general"]

#   backup_retention_period = 0
#   skip_final_snapshot     = true
#   deletion_protection     = false

#   tags = local.tags
# }

################################################################################
# Create key pair & EC2 instance - Active
################################################################################
resource "aws_key_pair" "ec2-active-keypair" {
  key_name   = "ec2-active-keypair"
  public_key = file("~/.ssh/id_rsa.pub")
}

module "ec2_active" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 2.0"

  name = "${local.ec2_name}-active"

  ami                    = "ami-08a52ddb321b32a8c"
  instance_type          = local.instance_class
  vpc_security_group_ids = [local.active_UDARR-Application]
  subnet_id              = var.active_public_subnets[0]
  key_name               = aws_key_pair.ec2-active-keypair.key_name

  tags = local.tags
}

################################################################################
# Create key pair & Create EC2 instance - Standby
################################################################################
resource "aws_key_pair" "ec2-standby-keypair" {
  provider = aws.region2

  key_name   = "ec2-standby-keypair"
  public_key = file("~/.ssh/id_rsa.pub")
}

module "ec2_standby" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 2.0"

  providers = {
    aws = aws.region2
  }

  name = "${local.ec2_name}-standby"

  ami                    = "ami-04e35eeae7a7c5883"
  instance_type          = local.instance_class
  vpc_security_group_ids = [local.standby_UDARR-Application]
  subnet_id              = var.standby_public_subnets[0]
  key_name               = aws_key_pair.ec2-standby-keypair.key_name

  tags = local.tags
}


################################################################################
# Create S3 bucket versioning enabled
################################################################################
resource "aws_iam_role" "this" {
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

data "aws_iam_policy_document" "bucket_policy" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "s3:GetObject",
    ]

    resources = [
      "arn:aws:s3:::${local.bucket_name}/*",
    ]
  }
}

module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = local.bucket_name

  force_destroy       = true
  acceleration_status = "Suspended"
  request_payer       = "BucketOwner"

  # Bucket policies
  attach_policy = true
  policy        = data.aws_iam_policy_document.bucket_policy.json

  # S3 bucket-level Public Access Block configuration (by default now AWS has made this default as true for S3 bucket-level block public access)
  block_public_acls       = true
  block_public_policy     = false
  ignore_public_acls      = true
  restrict_public_buckets = false

  # S3 Bucket Ownership Controls
  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_ownership_controls
  control_object_ownership = true
  object_ownership         = "BucketOwnerPreferred"

  expected_bucket_owner = data.aws_caller_identity.current.account_id

  acl = "private" # "acl" conflicts with "grant" and "owner"

  versioning = {
    status     = true
    mfa_delete = false
  }

  website = {
    index_document = "index.html"
    error_document = "error.html"
    routing_rules = [{
      condition = {
        key_prefix_equals = "docs/"
      },
      redirect = {
        replace_key_prefix_with = "documents/"
      }
    }]
  }

  cors_rule = [
    {
      allowed_methods = ["GET", "POST", "PUT", "DELETE", "HEAD"]
      allowed_origins = ["*"]
      allowed_headers = ["*"]
      expose_headers  = ["ETag"]
      max_age_seconds = 3000
    }
  ]

  tags = {
    Owner = "Cong Dinh"
  }
}
