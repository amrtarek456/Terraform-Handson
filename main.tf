provider "aws" {
  region = var.aws_region
}

#Configure AWS Provider
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "Production ${var.main_vpc_name}"
  }
}

#Create EC2 instance
resource "aws_instance" "server" {
  ami           = "ami-0b5eea76982371e91"
  instance_type = "t2.micro"
  tags = {
    "Name" = "Terraform"
  }
}

#Create a subnet
#Public Subnet 1a
resource "aws_subnet" "web" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.web_subnet_list[0]
  availability_zone = var.AZS[0]
  tags = {
    "Name" = "Web Public Subnet 1a"
  }
}
#Public Subnet 1b
resource "aws_subnet" "web2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.web_subnet_list[1]
  availability_zone = var.AZS[1]
  tags = {
    "Name" = "Web Public Subnet 1b"
  }
}
#Private Subnet 1a
resource "aws_subnet" "web3" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.web_subnet_list[2]
  availability_zone = var.AZS[0]
  tags = {
    "Name" = "Web Private Subnet 1a"
  }
}
#Private Subnet 1b
resource "aws_subnet" "web4" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.web_subnet_list[3]
  availability_zone = var.AZS[1]
  tags = {
    "Name" = "Web Pirvate Subnet 1b"
  }
}


#Create IGW 
resource "aws_internet_gateway" "my_web_igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    "Name" = "${var.main_vpc_name} IGW"
  }
}

#Create Route Table
resource "aws_default_route_table" "main_vpc_default_rt" {

  default_route_table_id = aws_vpc.main.main_route_table_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_web_igw.id
  }
  tags = {
    Name = "my-default-rt"
  }
}

#Create SG
resource "aws_default_security_group" "default_sec_group" {
  vpc_id = aws_vpc.main.id

  /*   ingress {
    cidr_blocks = [var.allow_all_ipv4_cidr_blocks]
    #cidr_blocks = [ var.my_public_ip ]
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
  }
  ingress {
    cidr_blocks = [var.allow_all_ipv4_cidr_blocks]
    from_port   = var.web_port
    protocol    = "tcp"
    to_port     = var.web_port
  }
  ingress {
    cidr_blocks = [var.allow_all_ipv4_cidr_blocks]
    from_port   = 8080
    protocol    = "tcp"
    to_port     = 8080
  } */

  dynamic "ingress" {
    for_each = var.ingress_ports
    iterator = i
    content {
      from_port   = i.value
      to_port     = i.value
      protocol    = "tcp"
      cidr_blocks = [var.allow_all_ipv4_cidr_blocks]
    }

  }
  egress {
    cidr_blocks = [var.allow_all_ipv4_cidr_blocks]
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
  }
  tags = {
    Name = "MyInstanceSecuirtyGroup"
  }
}

#Create Key Pair
resource "aws_key_pair" "test_ssh_key" {
  key_name   = "testing_ssh_key1"
  public_key = file(var.ssh_public_key)
}

#Create Instance with Key Name
#Public Instance on us-east-1a
resource "aws_instance" "my_vm" {
  ami                         = var.my_ami
  instance_type               = var.my_instance_type
  subnet_id                   = aws_subnet.web.id
  vpc_security_group_ids      = [aws_default_security_group.default_sec_group.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.test_ssh_key.key_name
  user_data                   = file("entry-script.sh")
  tags = {
    Name = "EC2 Public Subnet 1a"
  }

}

#Public Instance on us-east-1b
resource "aws_instance" "my_vm2" {
  ami                         = var.my_ami
  instance_type               = var.my_instance_type
  subnet_id                   = aws_subnet.web2.id
  vpc_security_group_ids      = [aws_default_security_group.default_sec_group.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.test_ssh_key.key_name
  user_data                   = file("entry-script.sh")
  tags = {
    Name = "EC2 Public Subnet 1b"
  }


  #Provisioner
  connection {
    type = "ssh"
    # bastion_user = "ubuntu"
    # bastion_host = aws_instance.bastion.public_ip
    user        = "ec2-user"
    host        = self.public_ip
    private_key = file("~/.ssh/test_rsa")
    timeout     = "60s"
  }

  provisioner "local-exec" {
    command = "echo public-ip1 ${aws_instance.my_vm.public_ip} '\n' public-ip2 ${aws_instance.my_vm2.public_ip} >> all-ips.txt"
  }
}

#Private Instance on us-east-1a
resource "aws_instance" "my_vm3" {
  ami                         = var.my_ami
  instance_type               = var.my_instance_type
  subnet_id                   = aws_subnet.web3.id
  vpc_security_group_ids      = [aws_default_security_group.default_sec_group.id]
  associate_public_ip_address = false
  key_name                    = aws_key_pair.test_ssh_key.key_name
  user_data                   = file("entry-script.sh")
  tags = {
    Name = "EC2 Private Subnet 1a"
  }
}
#Private Instance on us-east-1b
resource "aws_instance" "my_vm4" {
  ami                         = var.my_ami
  instance_type               = var.my_instance_type
  subnet_id                   = aws_subnet.web4.id
  vpc_security_group_ids      = [aws_default_security_group.default_sec_group.id]
  associate_public_ip_address = false
  key_name                    = aws_key_pair.test_ssh_key.key_name
  user_data                   = file("entry-script.sh")
  tags = {
    Name = "EC2 Private Subnet 1b"
  }
}

#----------Load Balancer Section----------#

#Create Application Load Balance
resource "aws_alb" "my_lb" {
  name               = "mylb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets = [
    aws_subnet.web.id,
    aws_subnet.web2.id,
  ]
}

#Create LB Listner
resource "aws_alb_listener" "lb_listener" {
  load_balancer_arn = aws_alb.my_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.lb_target_group.arn
    type             = "forward"
  }
}

#Create LB TG
resource "aws_alb_target_group" "lb_target_group" {
  name     = "mytg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
}

#Create LoadBalancer Target Group Attachment to my Instances
resource "aws_alb_target_group_attachment" "attach_target_group" {
  target_group_arn = aws_alb_target_group.lb_target_group.arn
  count            = 2
  target_id        = element(split(",", join(",", aws_instance.my_vm.*.id)), count.index)


  port = 80
}

#Create Load Balancer Secuirty Group
resource "aws_security_group" "lb_sg" {
  description = "Load Balancer Secuirty Group"
  vpc_id      = aws_vpc.main.id

  dynamic "ingress" {
    for_each = var.ingress_ports
    iterator = i
    content {
      from_port   = i.value
      to_port     = i.value
      protocol    = "tcp"
      cidr_blocks = [var.allow_all_ipv4_cidr_blocks]
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.allow_all_ipv4_cidr_blocks]
  }

  tags = {
    Name = "LoadBalancerSecuirtyGroup"
  }
}