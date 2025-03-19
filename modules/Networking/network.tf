resource "aws_vpc" "lms_vpc"{
 cidr_block = var.cidr_block
 
 tags = {
   Name = var.tag_name 
   environment = var.environment
 }
}

# Create internet gateway
resource "aws_internet_gateway" "lms_gateway" {
  vpc_id = aws_vpc.lms_vpc.id

  tags = {
    Name = var.gw_name
  
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_subnet" "lms_public_subnet" {
  for_each = toset(var.AZs)

  cidr_block = element(var.subnet_cidr, index(var.AZs, each.key))  # Map CIDR blocks to AZs
  vpc_id     = aws_vpc.lms_vpc.id
  map_public_ip_on_launch = true
  availability_zone = each.value

  tags = {
    Name        = "${var.public_subnet_name_prefix}-${each.key}"  # Use each.key for unique naming
    environment = var.environment
  }
}

# Create route table for public subnets
resource "aws_route_table" "lms_public_rt" {
    vpc_id = aws_vpc.lms_vpc.id 

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.lms_gateway.id
  }

  tags = {
    Name = var.public_rt_name
    Environment = var.environment
  }
}
# Associate public subnets with public route table
# resource "aws_route_table_association" "public_rt_association" {
#   subnet_id      =  aws_subnet.lms_public_subnet[each.key]
#   route_table_id = aws_route_table.lms_public.id
# }
resource "aws_route_table_association" "public_rt_association" {
  for_each = aws_subnet.lms_public_subnet

  subnet_id      = each.value.id
  route_table_id = aws_route_table.lms_public_rt.id
}


# Create security group for instances
resource "aws_security_group" "lms_sg" { 
  name        = var.sg_name
  vpc_id      = aws_vpc.lms_vpc.id
  tags = {
    Name = var.sg_name
    Environment = var.environment
  }
 
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
 # lms_console_client_tg
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/16"]
  }
  # https
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/16"]
  }
 #payment_api
  ingress {
    from_port       = 0
    to_port         = 9001
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/16"]
  }
  # ssh
  ingress {
    from_port    = 22
    to_port      = 22
    protocol     = "tcp"
    cidr_blocks = ["0.0.0.0/16"]
  }
 # mail_dev2
  ingress {
    from_port    = 0
    to_port      = 8082
    protocol     = "tcp"
    cidr_blocks = ["0.0.0.0/16"]
  }
  # meeting_api
  ingress {
    from_port    = 0
    to_port      = 8080
    protocol     = "tcp"
    cidr_blocks = ["0.0.0.0/12"]
  }
 # auth 
  ingress {
    from_port    = 0
    to_port      = 8081
    protocol     = "tcp"
    cidr_blocks = ["0.0.0.0/16"]
  }
  # lms_api_dev2
  ingress {
    from_port    = 0
    to_port      = 3000
    protocol     = "tcp"
    cidr_blocks = ["0.0.0.0/16"]
  }
  # mongodb
  ingress {
    from_port = 0
    to_port = 27017
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/16"]
  }
}