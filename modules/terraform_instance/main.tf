resource "aws_instance" "instance" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  tags = {
    Name = var.instance_name
  }

  vpc_security_group_ids = [var.security_group_id]

  user_data = var.user_data
}

output "instance_public_ip" {
  value = aws_instance.instance.public_ip
}
