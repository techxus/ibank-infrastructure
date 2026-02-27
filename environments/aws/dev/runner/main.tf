############################################
# environments/aws/dev/runners/main.tf
#
# PURPOSE:
# Creates self-hosted GitHub Actions runners
# inside the VPC so they can reach the private
# EKS endpoint without enabling public access.
#
# Resources:
# - IAM role          → runner can call AWS APIs
# - Security group    → outbound only, no inbound
# - Launch template   → EC2 configuration
# - Auto scaling group → self-healing runners
############################################

############################################
# DATA SOURCES
############################################

data "aws_secretsmanager_secret_version" "github_token" {
  secret_id = "ibank/github-runner-token"
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

############################################
# IAM ROLE FOR RUNNER
# Allows runner to:
# - Call EKS API
# - Pull from ECR
# - Read secrets
############################################

data "aws_iam_policy_document" "runner_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "runner" {
  name               = "ibank-${var.env}-github-runner"
  assume_role_policy = data.aws_iam_policy_document.runner_assume.json
  tags               = merge(var.tags, { Purpose = "github-runner" })
}

resource "aws_iam_role_policy_attachment" "runner_ssm" {
  role       = aws_iam_role.runner.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy" "runner" {
  name = "ibank-${var.env}-github-runner-policy"
  role = aws_iam_role.runner.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "eks:DescribeCluster",
          "eks:ListClusters"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = "arn:aws:secretsmanager:${var.region}:*:secret:ibank/*"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "runner" {
  name = "ibank-${var.env}-github-runner"
  role = aws_iam_role.runner.name
  tags = var.tags
}

############################################
# SECURITY GROUP
# Outbound only — runner calls out to GitHub
# and AWS APIs. Nothing calls into the runner.
############################################

resource "aws_security_group" "runner" {
  name        = "ibank-${var.env}-github-runner"
  description = "GitHub Actions runner - outbound only"
  vpc_id      = var.vpc_id

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "ibank-${var.env}-github-runner"
  })
}

############################################
# USER DATA
# Script that runs when EC2 starts:
# 1. Installs required tools
# 2. Registers runner with GitHub
# 3. Starts runner as a service
############################################

locals {
  user_data = base64encode(templatefile("${path.module}/runner.sh", {
    github_token         = data.aws_secretsmanager_secret_version.github_token.secret_string
    github_org           = var.github_org
    github_repo_infra    = var.github_repo_infra
    github_repo_platform = var.github_repo_platform
    cluster_name         = var.cluster_name
    region               = var.region
    env                  = var.env
  }))
}

############################################
# LAUNCH TEMPLATE
############################################

resource "aws_launch_template" "runner" {
  name_prefix   = "ibank-${var.env}-github-runner-"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = var.instance_type

  iam_instance_profile {
    name = aws_iam_instance_profile.runner.name
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.runner.id]
  }

  user_data = local.user_data

  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      volume_size           = 30
      volume_type           = "gp3"
      delete_on_termination = true
      encrypted             = true
    }
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required" # IMDSv2 required
    http_put_response_hop_limit = 1
  }

  tags = merge(var.tags, {
    Name = "ibank-${var.env}-github-runner"
  })

  tag_specifications {
    resource_type = "instance"
    tags = merge(var.tags, {
      Name = "ibank-${var.env}-github-runner"
    })
  }
}

############################################
# AUTO SCALING GROUP
# Keeps runner_count instances running.
# If instance dies ASG replaces it automatically.
############################################

resource "aws_autoscaling_group" "runner" {
  name                = "ibank-${var.env}-github-runner"
  desired_capacity    = var.runner_count
  min_size            = var.runner_count
  max_size            = var.runner_count * 2
  vpc_zone_identifier = var.private_subnet_ids

  launch_template {
    id      = aws_launch_template.runner.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "ibank-${var.env}-github-runner"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = var.env
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}