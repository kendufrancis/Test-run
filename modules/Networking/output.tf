output "vpc_id" {
  description = "The ID of the created VPC"
  value       = aws_vpc.lms_vpc.id  # Adjust this to match your VPC resource name
}
output "ubuntu_ami_id" {
  value = data.aws_ami.ubuntu.id  # Outputs the AMI ID
}

output "ubuntu_ami_name" {
  value = data.aws_ami.ubuntu.name  # Outputs the AMI name
}

output "public_subnet_ids" {
  value = [for subnet in aws_subnet.lms_public_subnet : subnet.id]
}

