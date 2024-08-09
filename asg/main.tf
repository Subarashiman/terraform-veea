terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  required_version = ">= 1.2.0"
}


# 인스턴스 중지
resource "null_resource" "stop_instance" {
  provisioner "local-exec" {
    command = "aws ec2 stop-instances --instance-ids ${data.aws_instance.instance_1.id} --region ap-northeast-2"
  }
}

# AMI 생성 (인스턴스 중지 후)
resource "aws_ami_from_instance" "toyproject_ami" {
  name               = "toyproject_ami"
  source_instance_id = data.aws_instance.instance_1.id

  tags = {
    Name = "toyproject_ami"
  }

  depends_on = [null_resource.stop_instance]
}

# 시작템플릿 생성
resource "aws_launch_template" "toyproject_launch_template" {
  name_prefix   = "web-server-"
  image_id      = aws_ami_from_instance.toyproject_ami.id
  instance_type = "t2.micro"
  key_name      = data.aws_key_pair.aws5.key_name ## 

  network_interfaces {
    associate_public_ip_address = true
    device_index                = 0
    security_groups             = [data.aws_security_group.selected.id]
  }
}

resource "aws_autoscaling_group" "toyproject-asg" {
  desired_capacity     = 2
  max_size             = 4
  min_size             = 2
  launch_template        { ###
    id      = aws_launch_template.toyproject_launch_template.id
    version = "$Latest"
  }
  vpc_zone_identifier  = [
   data.aws_subnet.subnet_az1.id,
   data.aws_subnet.subnet_az2.id
  ]
     target_group_arns = [data.aws_lb_target_group.toyproject-lb.arn]


  tag {
    key                 = "Name"
    value               = "toyproject-asg"
    propagate_at_launch = true
  }

  depends_on = [
    resource.aws_ami_from_instance.toyproject_ami
  ]
}