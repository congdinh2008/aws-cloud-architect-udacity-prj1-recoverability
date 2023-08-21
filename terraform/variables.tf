variable "region1" {
  type        = string
  description = "value of region1"
  default     = null
}

variable "region2" {
  type        = string
  description = "value of region2"
  default     = null
}


variable "vpc_active_id" {
  type        = string
  description = "value of vpc_active_id"
  default     = null
}

variable "vpc_standby_id" {
  type        = string
  description = "value of vpc_standby_id"
  default     = null
}

variable "vpc_active_cidr_block" {
  type        = string
  description = "value of vpc_active_cidr_block"
  default     = null
}

variable "vpc_standby_cidr_block" {
  type        = string
  description = "value of vpc_standby_cidr_block"
  default     = null
}

variable "active_private_subnets" {
  type        = list(string)
  description = "value of active_private_subnets"
  default     = null
}

variable "standby_private_subnets" {
  type        = list(string)
  description = "value of standby_private_subnets"
  default     = null
}

variable "rds_name" {
  type        = string
  description = "value of rds_name"
  default     = null
}

variable "ec2_name" {
  type        = string
  description = "name of ec2"
  default     = null
}

variable "active_public_subnets" {
  type        = list(string)
  description = "value of active_public_subnets"
  default     = null
}

variable "standby_public_subnets" {
  type        = list(string)
  description = "value of standby_public_subnets"
  default     = null
}

variable "s3_name" {
  type        = string
  description = "name of s3 bucket"
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "value of tags"
  default     = null
}
