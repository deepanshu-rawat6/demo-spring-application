provider "aws" {
  region = "us-east-1"
}

## IAM role for the instances to acccess S3 bucket
# Role permissions required:
# ECS_FullAccess
# S3_Push Access (or maybe Full_Access)
# Task Execution Role for loggs of ECS Tasks + Cloud Watch Access

resource "aws_launch_template" "jenkins_lt" {
  name = "tf_jenkins-launch-template"

  instance_type = "t3.xlarge"
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
      volume_size = 60
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
  name             = "tf_jenkins_asg"
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

output "lt_id" {
  value = aws_launch_template.jenkins_lt.id
}
