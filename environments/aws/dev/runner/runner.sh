#!/bin/bash
set -e

############################################
# user_data.sh
#
# Runs on EC2 startup to:
# 1. Install tools (kubectl, helm, aws cli, terragrunt)
# 2. Configure kubectl for EKS
# 3. Register GitHub Actions runner
# 4. Start runner as systemd service
############################################

# Update and install dependencies
apt-get update -y
apt-get install -y \
  curl \
  unzip \
  git \
  jq \
  wget \
  apt-transport-https \
  ca-certificates \
  gnupg

############################################
# Install AWS CLI v2
############################################
curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o /tmp/awscliv2.zip
unzip -q /tmp/awscliv2.zip -d /tmp
/tmp/aws/install
rm -rf /tmp/aws /tmp/awscliv2.zip

############################################
# Install kubectl
############################################
curl -fsSL "https://dl.k8s.io/release/$(curl -fsSL https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" \
  -o /usr/local/bin/kubectl
chmod +x /usr/local/bin/kubectl

############################################
# Install Helm
############################################
curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

############################################
# Install Terraform
############################################
curl -fsSL https://releases.hashicorp.com/terraform/1.5.0/terraform_1.5.0_linux_amd64.zip \
  -o /tmp/terraform.zip
unzip -q /tmp/terraform.zip -d /usr/local/bin
rm /tmp/terraform.zip

############################################
# Install Terragrunt
############################################
wget -q https://github.com/gruntwork-io/terragrunt/releases/download/v0.99.4/terragrunt_linux_amd64 \
  -O /usr/local/bin/terragrunt
chmod +x /usr/local/bin/terragrunt

############################################
# Configure kubectl for EKS
############################################
aws eks update-kubeconfig \
  --name ${cluster_name} \
  --region ${region}

############################################
# Create runner user
############################################
useradd -m -s /bin/bash runner
usermod -aG sudo runner

# Copy kubeconfig to runner user
mkdir -p /home/runner/.kube
cp /root/.kube/config /home/runner/.kube/config
chown -R runner:runner /home/runner/.kube

############################################
# Install GitHub Actions runner
############################################
RUNNER_VERSION=$(curl -fsSL https://api.github.com/repos/actions/runner/releases/latest \
  | jq -r '.tag_name' | sed 's/v//')

mkdir -p /home/runner/actions-runner
cd /home/runner/actions-runner

curl -fsSL \
  "https://github.com/actions/runner/releases/download/v$${RUNNER_VERSION}/actions-runner-linux-x64-$${RUNNER_VERSION}.tar.gz" \
  -o runner.tar.gz
tar xzf runner.tar.gz
rm runner.tar.gz
chown -R runner:runner /home/runner/actions-runner

############################################
# Get registration token from GitHub API
############################################
# NEW - repo level (register for both repos)
REG_TOKEN=$(curl -fsSL \
  -X POST \
  -H "Authorization: token ${github_token}" \
  -H "Accept: application/vnd.github.v3+json" \
  "https://api.github.com/repos/${github_org}/${github_repo_infra}/actions/runners/registration-token" \
  | jq -r '.token')

sudo -u runner /home/runner/actions-runner/config.sh \
  --url "https://github.com/${github_org}/${github_repo_infra}" \

############################################
# Register runner with GitHub org
# Labels help workflows target this runner
############################################
sudo -u runner /home/runner/actions-runner/config.sh \
  --url "https://github.com/${github_org}" \
  --token "$REG_TOKEN" \
  --name "ibank-${env}-runner-$(hostname)" \
  --labels "ibank,${env},eks,aws" \
  --runnergroup "Default" \
  --unattended \
  --replace

############################################
# Install and start runner as systemd service
############################################
cd /home/runner/actions-runner
./svc.sh install runner
./svc.sh start

echo "GitHub Actions runner setup complete"