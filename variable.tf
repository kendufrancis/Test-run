variable "region" {
  type = string
}
variable "cidr_block" {
type = string
}
variable "tag_name" {
type = string
}
variable "environment"{
type = string
}
variable "vpc_name" {
type = string
}
variable "gw_name" {
type = string
}

variable "subnet_cidr" {
 type        = list(string)
 description = "Public Subnet CIDR values"
 default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "AZs" {
  type = list(string)
   description = "Public Subnet CIDR values"
   default = ["eu-north-1b","eu-north-1a"]
}

variable "public_subnet_name_prefix" {
}

variable "public_rt_name"{
 type = string
  
}

variable "sg_name" {
 type = string
}


# variable "nat_gateway_name" {
  
# }
# variable "nat_eip_name" {
  
# }
# variable "private_subnet_cidr_blocks" {
  
# }
# variable "private_subnet_name_prefix" {
  
# }
# variable "private_rt_name " {
  
# }


##########################################################

# ec2- launch configuration


variable "ami_name" {
  type        = string
  description = "The name of the AMI to use."
}

variable "launch_template_name" {
  type        = string
  default = "ecs_template"
  description = "The name of the launch template."
}

variable "instance_type" {
  type        = string
  description = "The EC2 instance type to use."
}

variable "iam_instance_profile" {
  type       = string
  description = "cluster role"
}
variable "key_name" {
  type        = string
  description = "The name of the EC2 key pair to use."
}

# variable "sg" {
#   type = string
#   # default = aws_security_group.sg
#   description = "The ID of the security group to use for the launch template."
# }

variable "instance_name" {
  type = string
  # default = lms
}

variable "desired_capacity" {
  type = number
}
  
variable "max_size" {
  type = number
}
variable "min_size" {
type = number
}
  
variable "user_data" {
  type        = string
  description = "The user data script to run on the instances."
}

variable "linked_role_arn" {
  type =string
  default = "arn:aws:iam::*:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
}


# alb variables 

variable "alb_name" {
  type = string
}

variable "http_target_group_name" {
  type = string
}
variable "healthy_threshold" {
  type = number
}
variable "unhealthy_threshold" {
  type = number
}
variable "health_check_interval" {
  type = number
}
variable "health_check_path" {
  type = string
}
variable "health_check_timeout" {
  type = number
}
variable "https_target_group_name" {
  type = string
}
variable "listener_port" {
  type = list(string)
}
variable "service_protocols" {
  description = "Map of service protocols"
  type        = map(string)
}
variable "service_ports" {
  description = "Map of service protocols"
  type        = map(string)
}
variable "load_balancer_type" {
  type = string
}