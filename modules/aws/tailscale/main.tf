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

resource "aws_instance" "router" {
  ami                         = data.aws_ami.amazon_linux_2023.id
  instance_type               = var.instance_type
  subnet_id                   = var.public_subnet_id
  vpc_security_group_ids      = [aws_security_group.router.id]
  associate_public_ip_address = true
  source_dest_check           = false

  user_data = <<-EOF
    #!/bin/bash
    set -euxo pipefail

    dnf update -y
    curl -fsSL https://tailscale.com/install.sh | sh

    cat >/etc/sysctl.d/99-tailscale.conf <<SYSCTL
    net.ipv4.ip_forward = 1
    net.ipv6.conf.all.forwarding = 1
    SYSCTL

    sysctl --system

    tailscale up \
      --authkey='${var.tailscale_auth_key}' \
      --hostname='ibank-${var.env}-tailscale-router' \
      --advertise-routes='${join(",", var.advertise_routes)}' \
      --accept-dns=false \
      --ssh
  EOF

  tags = merge(var.tags, {
    Name = "ibank-${var.env}-tailscale-router"
  })
}