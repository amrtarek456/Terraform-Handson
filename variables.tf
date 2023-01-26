variable "vpc_cidr_block" {
  default     = "10.0.0.0/16"
  description = "Variable of VPC CIDR block"
  type        = string
}

variable "allow_all_ipv4_cidr_blocks" {
  description = "Allow all IPv4 to SG"
}

variable "web_subnet_list" {
  description = "List of all Subnets CIDR Blocks"
  type        = list(string)
}

variable "web_subnet" {
  default     = "10.0.10.0/24"
  description = "Variable of Public Subnet 1 CIDR block"
  type        = string
}

variable "web_subnet_2" {
  description = "Variable of Public Subnet 2 CIDR block"
}

variable "web_subnet_3" {
  description = "Variable of Private Subnet 1 CIDR block"
}

variable "web_subnet_4" {
  description = "Variable of Private Subnet 2 CIDR block"
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
}

variable "subnet_zone" {
  default     = "us-east-1a"
  description = "Subnet zone"
  type        = string
}

variable "AZS" {
  description = "Avail. Zones in us-east-1"
  type        = list(string)
}

variable "main_vpc_name" {
  description = "Main VPC Name"
  type        = string

}

variable "my_public_ip" {

}

variable "my_ami" {

}

variable "my_instance_type" {

}

variable "ssh_public_key" {

}

variable "web_port" {
  type = number
}

variable "ingress_ports" {
  description = "Ingress ports list"
  type        = list(number)

}