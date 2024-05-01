resource "aws_security_group" "wp_sg" {
  name        = "${terraform.workspace}-wordpress-sg"
  description = "Security group for WordPress instance in ${terraform.workspace}"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${terraform.workspace}-wordpress-sg"
  }
}

resource "random_shuffle" "subnet" {
  input        = var.subnets
  result_count = 1
}

resource "aws_instance" "wordpress" {
  ami           = var.ami_id
  instance_type = local.env.instance_type
  key_name      = var.key_name
  subnet_id     = random_shuffle.subnet.result[0]

  vpc_security_group_ids = [aws_security_group.wp_sg.id]

  tags = {
    Name = "${terraform.workspace}-wordpress"
  }
}

resource "null_resource" "ansible_provisioner" {
  triggers = {
    instance_ip = aws_instance.wordpress.public_ip
  }

  provisioner "local-exec" {
    command = "ansible-playbook -i '${aws_instance.wordpress.public_ip},' -u ec2-user --private-key '${path.module}/devops.pem' playbook/wordpress_install.yml"
    environment = {
      ANSIBLE_HOST_KEY_CHECKING = "False"
    }
  }
}
