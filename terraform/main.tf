provider "aws" {
  region = "us-east-1"
}

# resource "aws_vpc" "main" {
#   cidr_block = "10.0.0.0/16"
#   tags = {
#     Name = "main-vpc"
#   }
# }

# resource "aws_internet_gateway" "igw" {
#   vpc_id = aws_vpc.main.id

#   tags = {
#     Name = "main-igw"
#   }
# }

# resource "aws_subnet" "public_subnet_1" {
#   vpc_id                  = aws_vpc.main.id
#   cidr_block              = "10.0.1.0/24"
#   map_public_ip_on_launch = true
#   availability_zone       = "us-east-1a"
# }

# resource "aws_subnet" "public_subnet_2" {
#   vpc_id                  = aws_vpc.main.id
#   cidr_block              = "10.0.2.0/24"
#   map_public_ip_on_launch = true
#   availability_zone       = "us-east-1b"
# }

# resource "aws_subnet" "public_subnet_3" {
#   vpc_id                  = aws_vpc.main.id
#   cidr_block              = "10.0.3.0/24"
#   map_public_ip_on_launch = true
#   availability_zone       = "us-east-1c"
# }

# resource "aws_route_table" "public_rt" {
#   vpc_id = aws_vpc.main.id

#   tags = {
#     Name = "main-public-rt"
#   }
# }

# resource "aws_route" "public_route" {
#   route_table_id         = aws_route_table.public_rt.id
#   destination_cidr_block = "0.0.0.0/0"
#   gateway_id             = aws_internet_gateway.igw.id
# }

# resource "aws_route_table_association" "public_assoc_1" {
#   subnet_id      = aws_subnet.public_subnet_1.id
#   route_table_id = aws_route_table.public_rt.id
# }

# resource "aws_route_table_association" "public_assoc_2" {
#   subnet_id      = aws_subnet.public_subnet_2.id
#   route_table_id = aws_route_table.public_rt.id
# }

# resource "aws_route_table_association" "public_assoc_3" {
#   subnet_id      = aws_subnet.public_subnet_3.id
#   route_table_id = aws_route_table.public_rt.id
# }

# resource "aws_security_group" "jenkins_sg" {
#   vpc_id = aws_vpc.main.id

#   ingress {
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   ingress {
#     from_port   = 8080
#     to_port     = 8080
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   ingress {
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }

# resource "aws_iam_role" "s3_access_role" {
#   name = "jenkins-s3-access-role"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [{
#       Action = "sts:AssumeRole",
#       Effect = "Allow",
#       Principal = {
#         Service = "ec2.amazonaws.com"
#       }
#     }]
#   })
# }

resource "aws_launch_template" "jenkins_lt" {
  name = "jenkins-launch-template"

  instance_type = "t2.large"
  image_id      = "ami-0e2c8caa4b6378d8c"

  iam_instance_profile {
    arn = "arn:aws:iam::971422682872:instance-profile/ecs-jenkins-access"
  }

  network_interfaces {
    security_groups = ["sg-0f853a9caaafe3dfa"]
    subnet_id       = "	subnet-07655f7c725dd23c9"
  }

  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      volume_size = 30
    }
  }

  instance_market_options {
    market_type = "spot"
  }

  key_name = "jenkins-aws-key-pair"

  ebs_optimized = "true"

  user_data = base64encode(file("./user_data.sh"))
}

resource "aws_autoscaling_group" "jenkins_asg" {
  min_size         = 1
  desired_capacity = 1
  max_size         = 4

  launch_template {
    id      = aws_launch_template.jenkins_lt.id
    version = "$Latest"
  }

  vpc_zone_identifier = [
    "subnet-01bcf31675cdd36e9", "subnet-05547da5478ff3548", "subnet-07655f7c725dd23c9", "subnet-0497c38b74213357f"
  ]

}

output "asg_id" {
  value = aws_autoscaling_group.jenkins_asg.id
}

# output "iam_role_name" {
#   value = aws_iam_role.s3_access_role.name
# }
