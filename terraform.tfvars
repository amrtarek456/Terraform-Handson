vpc_cidr_block             = "10.0.0.0/16"
allow_all_ipv4_cidr_blocks = "0.0.0.0/0"
web_subnet_list = [
  "10.0.0.0/24",
  "10.0.2.0/24",
  "10.0.1.0/24",
  "10.0.3.0/24",
]
web_subnet   = "10.0.0.0/24"
web_subnet_2 = "10.0.2.0/24"
web_subnet_3 = "10.0.1.0/24"
web_subnet_4 = "10.0.3.0/24"
aws_region   = "us-east-1"
subnet_zone  = "us-east-1a"
AZS = [
  "us-east-1a",
  "us-east-1b",
  "us-east-1c",
]
main_vpc_name    = "Main VPC"
my_public_ip     = "45.243.201.221"
my_ami           = "ami-0b5eea76982371e91"
my_instance_type = "t2.micro"
ssh_public_key   = "~/.ssh/test_rsa.pub"
web_port         = 80
ingress_ports = [
  22,
  80,
  8080,
]