region1 = "us-east-1"
region2 = "us-west-2"

# VPC values
vpc_active_id           = "vpc-048f426ab59e7aa6f"
vpc_standby_id          = "vpc-00403700726b032d2"
vpc_active_cidr_block   = "10.1.0.0/16"
vpc_standby_cidr_block  = "10.2.0.0/16"
active_private_subnets  = ["subnet-017071c5cf1ee5913", "subnet-0afed5dfe0ce0be9c"]
standby_private_subnets = ["subnet-040aed102050ce05c", "subnet-0c323bda074040bcd"]
active_public_subnets   = ["subnet-08dc786ac9a7d1629", "subnet-0774020665423e437"]
standby_public_subnets  = ["subnet-0ba0bcb700adb6c03", "subnet-0082fa65c118e4436"]

# RDS values
rds_name = "udacityprj1-rds"

# EC2 values
ec2_name = "udacityprj1-ec2"

# S3 values
s3_name = "udacityprj1-s3"
