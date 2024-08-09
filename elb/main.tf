terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  required_version = ">= 1.2.0"
}



# ALB 생성
resource "aws_lb" "toyproject-lb" {
  name               = "toyproject-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [data.aws_security_group.selected.id]
  subnets            = [data.aws_subnet.subnet_az1.id, data.aws_subnet.subnet_az2.id]

  tags = {
    Name = "toyproject_lb"
  }
}

# ALB Target Group 생성
resource "aws_lb_target_group" "toyproject-lb" {
  name        = "toyproject-lb"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.selected.id
  target_type = "instance"

  health_check {
    path                 = "/health"
    protocol             = "HTTP"
    healthy_threshold    = 2
    unhealthy_threshold  = 2
    interval             = 30
    timeout              = 5
  }

  tags = {
    Name = "toyproject-tg"
  }
}

# ALB Listener 생성
resource "aws_lb_listener" "toyproject_alb_listener" {
  load_balancer_arn = aws_lb.toyproject-lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.toyproject-lb.arn
  }
}


### autoscaling을 위해 빈 target group을 생성
# # Target Group에 인스턴스 추가
# resource "aws_lb_target_group_attachment" "instance_1" {
#   target_group_arn = aws_lb_target_group.toyproject-lb.arn
#   target_id        = data.aws_instance.instance_1.id
#   port             = 80
# }

# resource "aws_lb_target_group_attachment" "instance_2" {
#   target_group_arn = aws_lb_target_group.toyproject-lb.arn
#   target_id        = data.aws_instance.instance_2.id
#   port             = 80
# }