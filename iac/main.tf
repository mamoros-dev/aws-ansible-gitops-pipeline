terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region  = "us-east-1"
  # profile = "personal"
}

# 1. Clave SSH pública
resource "aws_key_pair" "mi_clave_ssh" {
  key_name   = "clave-ansible-dynamic"
  public_key = file("~/.ssh/aws_ansible_key.pub")
}

# 2. Grupo de Seguridad (Firewall)
resource "aws_security_group" "sg_web" {
  name        = "sg_ansible_dynamic"
  description = "Permitir SSH y HTTP"

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
}

# 3. AMI de Ubuntu Jammy 22.04
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

# 4. Instancia EC2 con TAGS ESTRATÉGICOS
resource "aws_instance" "servidor_web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  key_name               = aws_key_pair.mi_clave_ssh.key_name
  vpc_security_group_ids = [aws_security_group.sg_web.id]

  # ESTAS ETIQUETAS LAS LEERÁ ANSIBLE DE FORMA DINÁMICA:
  tags = {
    Name        = "EC2-Ansible-Dynamic"
    Environment = "Dev"
    Role        = "webservers" # <-- Tag principal de filtrado
  }
}

output "ip_publica_servidor" {
  value       = aws_instance.servidor_web.public_ip
  description = "IP Pública asignada a la instancia EC2"
}

# Creamos un secreto seguro en AWS Systems Manager Parameter Store
resource "aws_ssm_parameter" "token_terceros" {
  name        = "/produccion/servicios/token_api"
  description = "Token de API de terceros gestionado desde AWS SSM"
  type        = "SecureString"
  value       = "token_aws_ssm_super_secreto_2026_xyz"

  tags = {
    Environment = "Produccion"
  }
}