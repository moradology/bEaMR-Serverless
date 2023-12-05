resource "aws_emrserverless_application" "spark" {
  name                 = var.name
  type                 = "spark"
  release_label        = var.release_label

  image_configuration {
    image_uri          = var.image_uri
  }

  architecture         = var.architecture
  maximum_capacity {
    cpu                = var.max_cpu
    memory             = var.max_memory
  }

  network_configuration {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = var.emr_sg_ids
  }
  tags                 = var.tags
}

resource "aws_iam_policy" "emr_serverless_ecr_policy" {
  name        = "emr-serverless-ecr-policy"
  description = "Policy to grant ECR permissions to EMR Serverless"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
        ],
        Effect   = "Allow",
        Resource = "arn:aws:ecr:${var.ecr_region}:${var.ecr_account_id}:repository/${var.ecr_repository_name}",
      },
    ],
  })
}

resource "aws_iam_policy_attachment" "emr_serverless_ecr_policy_attachment" {
  policy_arn = aws_iam_policy.emr_serverless_ecr_policy.arn
  roles      = [aws_iam_role.emr_serverless_role.name]
}