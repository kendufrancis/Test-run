data "aws_ami" "ami" {
  most_recent = true
  owners = [var.ami_owner]

  filter {
    name   = "name"
    values = ["${var.ami_name}*"]
  }
}

data "aws_caller_identity" "current" {}


resource "aws_key_pair" "my_key" {
  key_name   = "lms_key"                  
  public_key = file("~/.ssh/lms_key.pub")  # Path to your public key file
}

# Provisioner to generate an SSH key pair
resource "null_resource" "generate_key_pair" {
  provisioner "local-exec" {
    command = <<EOF
      ssh-keygen -t rsa -b 2048 -f ~/.ssh/lms_key -N ""
EOF
  }
}

resource "aws_iam_role" "lms_ecs_instance_role" {
  name               = "ecsInstanceRole"
  assume_role_policy = data.aws_iam_policy_document.ecs_instance_assume_role_policy.json
}

resource "aws_iam_instance_profile" "ecs_instance_profile" {
  name = "ecsInstanceProfile" 
  role = aws_iam_role.lms_ecs_instance_role.name
}

data "aws_iam_policy_document" "ecs_instance_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}


resource "aws_launch_template" "lms_launch_template" {
  name = var.launch_template_name
  tags = {
    Name = var.launch_template_name
    Environment = var.environment
  }
  image_id = data.aws_ami.ami.id
  iam_instance_profile {
    arn = var.iam_instance_profile
  }
  instance_type = var.instance_type
  key_name = var.key_name
  metadata_options {
    http_endpoint  = "enabled"
    http_put_response_hop_limit = 2
    http_tokens  = "required"

  }  

  instance_market_options {
    market_type = "spot"
    spot_options {
      max_price = "0.03"
    }
  }
block_device_mappings {
   device_name = "/dev/xvda"
   ebs {
     volume_size = 30
     volume_type = "gp2"
   }
 }

  monitoring {
    enabled = true
  }
  network_interfaces {
    security_groups  = [var.sg_name]
  }
  tag_specifications {
    tags = {
      name = var.instance_name
    }

    resource_type = "instance"
  }

  user_data =  var.user_data
}


resource "aws_autoscaling_group" "ecs_asg" {
 vpc_zone_identifier = aws_subnet.lms_public_subnet.id
 desired_capacity    = var.desired_capacity
 max_size            = var.max_size
 min_size            = var.min_size

 launch_template {
   id      = aws_launch_template.lms_launch_template.id
   version = "$Latest"
 }

 tag {
   key                 = "AmazonECSManaged"
   value               = "ecs-instance"
   propagate_at_launch = true
 }
}

# Execution Role
resource "aws_iam_role" "ecs_execution_role" {
  name = "ecs_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        #sid = ""
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
        
         #Condition = {
           #ArnLike" = {
            #"aws:SourceArn":"arn:aws:ecs:eu-north-1:${secret.ACCOUNT_ID}"
          #}
      }
    ]
  })
  tags = {
    tag-key = "cluster_role"
  }
}
# Additional Policy for ECR Access
resource "aws_iam_policy" "ecs_access_policy" {
  name        = "ECSAccessPolicy"
  description = "IAM policy for ECS cluster role"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecs:RegisterContainerInstance",
          "ecs:DeregisterContainerInstance",
          "ecs:DiscoverPollEndpoint",
          "ecs:Submit*",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:GetAuthorizationToken",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      }
    ]
  })
}

# Attach Policies to Execution Role
resource "aws_iam_role_policy_attachment" "ecs_execution_role_policy_attachment" {
  policy_arn = aws_iam_role.ecs_execution_role_policy.arn     # "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  role       = aws_iam_role.ecs_execution_role.name
}

# Task Role
resource "aws_iam_role" "ecs_task_role" {
  name = "ecs_task_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}
resource "aws_iam_policy" "ecs_task_policy" {
  name        = "ecs-cluster-policy"
  description = "IAM policy for ECS cluster role"
 
  policy = jsonencode({
    "Version": "2012-10-17",  
    "Statement": [  
        {  
            "Effect": "Allow",  
            "Action": [  
                "s3:PutObject",  
                "s3:GetObject",  
                "s3:ListBucket"  
            ],  
            "Resource": [  
                "arn:aws:s3:::your-bucket-name",  
                "arn:aws:s3:::your-bucket-name/*"  
            ]  
        }  
    ]  
})
}

# Attach Policies to Task Role
resource "aws_iam_role_policy_attachment" "ecs_task_dynamodb_access" {
  policy_arn = aws_iam_policy.ecs_task_policy.arn
  role       = aws_iam_role.ecs_task_role.name
}
