provider "aws" {
  region = "ap-northeast-2"
}


# 기존 VPC 찾기
data "aws_vpc" "selected" {
  filter {
    name   = "tag:Name"
    values = ["toy-project-vpc"]
  }
}

# ap-northeast-2a 서브넷 찾기
data "aws_subnet" "subnet_az1" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }

  filter {
    name   = "availability-zone"
    values = ["ap-northeast-2a"]
  }

  filter {
    name   = "tag:Name"
    values = ["public-subnet-az1"]
  }
}

# ap-northeast-2c 서브넷 찾기
data "aws_subnet" "subnet_az2" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }

  filter {
    name   = "availability-zone"
    values = ["ap-northeast-2c"]
  }

  filter {
    name   = "tag:Name"
    values = ["public-subnet-az2"]
  }
}

# 기존 보안 그룹 찾기
data "aws_security_group" "selected" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }

  filter {
    name   = "tag:Name"
    values = ["web-tier-instance-sg"]
  }
}

# 키 페어 찾기
data "aws_key_pair" "aws5" {
    key_name           = "aws5"
    include_public_key = true

    filter {
      name  = "tag:Name"
      values = ["aws5"]
    }
}

# # ami id 찾기
# data "aws_ami_from_instance" "toyproject_ami" {
#     filter {
#         name  = "tag:Name"
#         value = ["toyproject_ami"]
#     }
# }

# ap-northeast-2a 인스턴스 찾기
data "aws_instance" "instance_1" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }

  filter {
    name   = "availability-zone"
    values = ["ap-northeast-2a"]
  }

  filter {
    name   = "tag:Name"
    values = ["toyproject_instance_1"]
  }
}
# target_group_arns = [aws_lb_target_group.app-tier-alb-tg.arn]
# 로드밸런서의 대상그룹 찾기
data "aws_lb_target_group" "toyproject-lb" {
    name = "toyproject-lb"
}

# # ap-northeast-2c 인스턴스 찾기
# data "aws_instance" "instance_2" {
#   filter {
#     name   = "vpc-id"
#     values = [data.aws_vpc.selected.id]
#   }

#   filter {
#     name   = "availability-zone"
#     values = ["ap-northeast-2c"]
#   }

#   filter {
#     name   = "tag:Name"
#     values = ["toyproject_instance_2"]
#   }
# }
