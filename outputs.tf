output "ec2_public_ip" {
  description = "the public ip address of ec2 instance"
  value       = aws_instance.my_vm.public_ip
}

output "vpc_id" {
  value = aws_vpc.main.id
}
