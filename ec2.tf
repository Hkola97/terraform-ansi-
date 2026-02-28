resource "aws_security_group" "ssh" {
  name = "allow_ssh"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
   ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

    egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "ansible_server" {
  ami           = var.aws-instance-id
  instance_type = "t3.micro"

  vpc_security_group_ids = [aws_security_group.ssh.id]

  tags = {
    Name = "Ansible-Server"
  }

  # ---------- CONNECTION ----------
  connection {
    type     = "ssh"
    host     = self.public_ip
    user     = "ec2-user"
    password = "DevOps321"   # OR private_key = file("key.pem")
    timeout  = "5m"
  }

  # ---------- REMOTE EXEC ----------
  provisioner "remote-exec" {
    inline = [

      "echo 'Updating packages...'",

      # Amazon Linux / RHEL
      "sudo yum update -y",

      "echo 'Installing EPEL repo'",
      "sudo yum install epel-release -y",

      "echo 'Installing Ansible'",
      "sudo yum install ansible -y",

      "echo 'Check Ansible Version'",
      "ansible --version"
    ]
  }
}
output "ansible_server_public_ip" {
  value = aws_instance.ansible_server.public_ip
}
