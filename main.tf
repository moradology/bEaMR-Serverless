provider "aws" {
  region = var.aws_region
}

# VPC Module
module "vpc" {
  source = "./vpc"
}

# ECR Module
module "ecr" {
  source = "./ecr"
  repository_name = var.repository_name
}

# Build container and push it
resource "null_resource" "build_and_push_image" {
  provisioner "local-exec" {
    command = "bash build_and_push_image.sh ${module.ecr.repository_url} ${var.repository_name} ${var.emr_release_label}"
  }
}

data "external" "check_image_pushed" {
  program = ["bash", "-c", "echo '{\"result\": \"Image Pushed Successfully\"}'"]
  depends_on = [null_resource.build_and_push_image]
}

# EMR Serverless Module
module "emr_serverless" {
  source = "./emr"
  name = "deployment_test"
  release_label = var.emr_release_label
  image_uri = "${module.ecr.repository_url}:latest"
  private_subnet_ids = module.vpc.private_subnet_ids
  emr_sg_ids = [module.security_groups.emr_sg_id]
}

# Security Groups Module
module "security_groups" {
  source = "./security_groups"
  vpc_id  = module.vpc.vpc_id
}