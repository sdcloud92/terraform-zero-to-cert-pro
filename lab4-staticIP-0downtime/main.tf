provider "aws" {
  region = "us-east-1"
}

(* #Static IP so that our Instance maintains the same PublicIP address *)
resource "aws_eip" "web_instance_eip" {
  instance = aws_instance.web_instance.id
  tags = {
    Name  = "eip for Webserver Built by Terraform"
    Owner = "Cloud Jedi"
  }
}

resource "aws_instance" "web_instance" {
  ami                    = "ami-0f34c5ae932e6f0e4" #amazon linux 2
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.web_instance_sg.id]
  user_data              = file("user-data.sh")
  tags = {
    Name  = "Webserver Built by Terraform"
    Owner = "Cloud Jedi"
  }
(*   #Will create a new instance before the previous is destroy to ensure no downtime *)
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "web_instance_sg" {
  name        = "web_instance_sgs"
  description = "Allow inbound http and https traffic"

  dynamic "ingress" {
    for_each = ["80", "8080", "443", "80", "22"] #list of ports we want to create
    content {
      description = "Allowance of ports 80, 8080, 443, 80, 22"
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = {
    Name  = "Web_Instance_SG"
    Owner = "Cloud Jedi"
  }
}



