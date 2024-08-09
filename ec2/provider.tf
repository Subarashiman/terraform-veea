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