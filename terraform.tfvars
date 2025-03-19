
#networking
  region             = "eu-north-1"
  cidr_block      = "10.0.0.0/16"
  tag_name                   = "lms-infra"
  environment                = "staging"
  vpc_name                   = "Project VPC"
  gw_name                    =  "lms_gateway"
  AZs                         = ["eu-north-1b","eu-north-1a"]
  subnet_cidr = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnet_name_prefix  = "lms"
  sg_name                    = "lms-sg"
  public_rt_name             = "lms-rt-public"
  

# ec2- launch configuration

ami_name =  "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
launch_template_name = "lms-launch-template"
instance_type = "t2.micro"
key_name =  "lms_key"
instance_name = "lms-instance"
linked-role-arn = "arn:aws:iam::*:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
iam_instance_profile = "arn:aws:iam::*:instance-profile/ecsInstanceRole"
min_size = 1
max_size = 3
desired_capacity = 2
user_data = <<EOF
#!/bin/bash
echo ECS_CLUSTER=prod-us-east-2-ecs >> /etc/ecs/ecs.config
start ecs
EOF

  # alb
alb_name ="lms_api_lb"
healthy_threshold = 2
http_target_group_name = "lms-api-http"
https_target_group_name = "lms-api-https"
health_check_interval = 30
unhealthy_threshold = 3
health_check_path = "/health"
health_check_timeout = 5
service_protocols = {
  http  = "HTTP"
  https = "HTTPS"
}
service_ports = {
  http     = "tcp"
  https    = "tcp"
}
target_type = data.aws_ami.ami.id  
load_balancer_type = "application"
# target_group_port = 3000
# listener_port = [ 80, 443] 