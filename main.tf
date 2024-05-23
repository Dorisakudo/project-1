provider "aws" {
  region = var.aws_region
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

module "security_group" {
  source = "./modules/security_group"
  security_group_name = var.security_group_name
}

module "jenkins_instance" {
  source              = "./modules/jenkins_instance"
  ami_id              = data.aws_ami.ubuntu.id
  instance_type       = var.instance_type
  key_name            = var.key_name
  security_group_id   = module.security_group.security_group_id
  instance_name       = "Jenkins"

  user_data = <<-EOF
#!/bin/bash
sudo apt update -y
sudo apt install fontconfig openjdk-17-jre -y
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]" \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update -y
sudo apt-get install jenkins -y
sudo systemctl start jenkins
sudo systemctl enable jenkins
EOF
}

module "terraform_instance" {
  source              = "./modules/terraform_instance"
  ami_id              = data.aws_ami.ubuntu.id
  instance_type       = var.instance_type
  key_name            = var.key_name
  security_group_id   = module.security_group.security_group_id
  instance_name       = "Terraform"

  user_data = <<-EOF
#!/bin/bash
sudo apt-get update -y && sudo apt install openjdk-11-jdk -y
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common curl
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update -y && sudo apt-get install terraform -y
sudo mv terraform /usr/local/bin
sudo apt-get update -y
sudo apt-get install -y apt-transport-https ca-certificates curl
sudo mkdir -p -m 755 /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.27/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
sudo chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.27/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo chmod 644 /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update -y
sudo apt-get install -y kubectl
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo apt install unzip -y
unzip awscliv2.zip
sudo ./aws/install
EOF
}

