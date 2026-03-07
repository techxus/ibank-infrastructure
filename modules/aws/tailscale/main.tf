data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["137112412989"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023*-x86_64"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

resource "aws_security_group" "router" {
  name        = "ibank-${var.env}-tailscale-router"
  description = "Tailscale subnet router"
  vpc_id      = var.vpc_id

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "ibank-${var.env}-tailscale-router"
  })
}

resource "aws_iam_role" "router" {
  name = "ibank-${var.env}-tailscale-router-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy" "router" {
  name = "ibank-${var.env}-tailscale-router-policy"
  role = aws_iam_role.router.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameter"
        ]
        Resource = "arn:aws:ssm:${var.region}:*:parameter${var.tailscale_auth_key_ssm_parameter_name}"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "router" {
  name = "ibank-${var.env}-tailscale-router-profile"
  role = aws_iam_role.router.name
}

resource "aws_instance" "router" {
  ami                         = data.aws_ami.amazon_linux_2023.id
  instance_type               = var.instance_type
  subnet_id                   = var.public_subnet_id
  vpc_security_group_ids      = [aws_security_group.router.id]
  associate_public_ip_address = true
  source_dest_check           = false
  iam_instance_profile        = aws_iam_instance_profile.router.name

  user_data = <<-EOF
    #!/bin/bash
    set -euxo pipefail

    dnf update -y
    dnf install -y awscli
    curl -fsSL https://tailscale.com/install.sh | sh

    cat >/etc/sysctl.d/99-tailscale.conf <<SYSCTL
    net.ipv4.ip_forward = 1
    net.ipv6.conf.all.forwarding = 1
    SYSCTL

    sysctl --system

    AUTH_KEY=$(aws ssm get-parameter \
      --name "${var.tailscale_auth_key_ssm_parameter_name}" \
      --with-decryption \
      --query 'Parameter.Value' \
      --output text \
      --region "${var.region}")

    tailscale up \
      --authkey="$AUTH_KEY" \
      --hostname="ibank-${var.env}-tailscale-router" \
      --advertise-routes="${join(",", var.advertise_routes)}" \
      --accept-dns=false \
      --ssh
  EOF

  tags = merge(var.tags, {
    Name = "ibank-${var.env}-tailscale-router"
  })
}