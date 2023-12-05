variable "name" {
  description = "Name of the EMR Serverless application"
  type        = string
}

variable "release_label" {
  description = "Release label for the EMR Serverless application"
  type        = string
  default     = "emr-6.12"
}

variable "architecture" {
  description = "The CPU architecture of an application. Valid values are `ARM64` or `X86_64`. Default value is `X86_64`"
  type        = string
  default     = "ARM64"
}

variable "image_uri" {
  description = "The URI corresponding to an ECR backed image; used by all worker types"
  type        = string
}

variable "max_cpu" {
  description = "Maximum cpu capacity configuration for the EMR Serverless application"
  type        = string
  default     = "48 vCPU"
}

variable "max_memory" {
  description = "Maximum memory capacity configuration for the EMR Serverless application"
  type        = string
  default     = "144 GB"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "List of private subnet IDs"
}

variable "emr_sg_ids" {
  type        = list(string)
  description = "ID of the EMR security group"
}

variable "tags" {
  description = "Tags for the EMR Serverless application"
  type        = map(string)
  default = {
    Terraform   = "true"
    Environment = "dev"
  }
}

variable "ecr_repository_name" {
  description = "Name of the ECR repository"
  type = string
}

variable "ecr_region" {
  description = "AWS region where the ECR repository is located"
  type = string
}

variable "ecr_account_id" {
  description = "AWS account ID where the ECR repository is located"
  type = string
}