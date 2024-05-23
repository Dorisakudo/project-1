output "jenkins_public_ip" {
  value = module.jenkins_instance.instance_public_ip
}

output "terraform_public_ip" {
  value = module.terraform_instance.instance_public_ip
}
