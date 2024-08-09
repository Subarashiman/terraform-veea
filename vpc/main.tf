terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}


# VPC 생성
resource "aws_vpc" "toy-project-vpc" {
  cidr_block = "192.168.0.0/16"
  enable_dns_hostnames = true 
  enable_dns_support = true
  tags = {
    Name = "toy-project-vpc"
  }
}

# Subnet 생성 (6EA)
# pub_sub-1
resource "aws_subnet" "public-subnet-az1" {
    cidr_block = "192.168.1.0/24"
    vpc_id = aws_vpc.toy-project-vpc.id
    availability_zone = "ap-northeast-2a"
    map_public_ip_on_launch = true # 퍼블릭 ip 주소 할당
    tags = {
      Name = "public-subnet-az1"
  }
}

# pri-sub-1
resource "aws_subnet" "private-subnet-az1" {
    cidr_block = "192.168.10.0/24"
    vpc_id = aws_vpc.toy-project-vpc.id
    availability_zone = "ap-northeast-2a"
    tags = {
      Name = "private-subnet-az1"
  }
}

# pri-db-sub-1
resource "aws_subnet" "private-db-subnet-az1" {
    cidr_block = "192.168.100.0/24"
    vpc_id = aws_vpc.toy-project-vpc.id
    availability_zone = "ap-northeast-2a"
    tags = {
      Name = "private-db-subnet-az1"
  }
}

# pub-sub-2
resource "aws_subnet" "public-subnet-az2" {
    cidr_block = "192.168.2.0/24"
    vpc_id = aws_vpc.toy-project-vpc.id
    availability_zone = "ap-northeast-2c"
    map_public_ip_on_launch = true # 해당 서브넷 선택 인스턴스는 퍼블릭 IP 주소 할당
    tags = {
      Name = "public-subnet-az2"
  }
}

# pri-sub-2
resource "aws_subnet" "private-subnet-az2" {
    cidr_block = "192.168.20.0/24"
    vpc_id = aws_vpc.toy-project-vpc.id
    availability_zone = "ap-northeast-2c"
    tags = {
      Name = "private-subnet-az2"
  }
}

# db-sub-2
resource "aws_subnet" "private-db-subnet-az2" {
    cidr_block = "192.168.200.0/24"
    vpc_id = aws_vpc.toy-project-vpc.id
    availability_zone = "ap-northeast-2c"
    tags = {
      Name = "private-db-subnet-az2"
  }
}

# # NAT Gateway용 EIP 생성(2ea) - 공인 IP Release에 시간이 2~3분 가량 소요되는 점 참조
# resource "aws_eip" "ngw-eip1" {
#     vpc = true
# }

# resource "aws_eip" "ngw-eip2" {
#     vpc = true
# }

# # NAT Gateway 생성(2ea)
# resource "aws_nat_gateway" "ngw-az1" {
#     allocation_id = aws_eip.ngw-eip1.id
#     subnet_id = aws_subnet.public-subnet-az1.id
#     tags = {
#         Name = "ngw-public-az1"
#     }
# }

# resource "aws_nat_gateway" "ngw-az2" {
#     allocation_id = aws_eip.ngw-eip2.id
#     subnet_id = aws_subnet.public-subnet-az2.id
#     tags = {
#         Name = "ngw-public-az2"
#     }
# }

# Internet Gateway(IGW) 생성
resource "aws_internet_gateway" "toy-project-igw" {
    vpc_id = aws_vpc.toy-project-vpc.id
    tags = {
      Name = "toy-project-igw"
    }
}

# Default Routing table ID 획득
locals {
  default_route_table_id = aws_vpc.toy-project-vpc.default_route_table_id
}

# Default Routing table의 Route 설정 추가
resource "aws_route" "default-rt-to-igw" {
  route_table_id = local.default_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.toy-project-igw.id
}

# 명시적 서브넷 설정
resource "aws_route_table_association" "public-subnet-az1" {
  subnet_id = aws_subnet.public-subnet-az1.id
  route_table_id = local.default_route_table_id
}
# 명시적 서브넷 설정
resource "aws_route_table_association" "public-subnet-az2" {
  subnet_id = aws_subnet.public-subnet-az2.id
  route_table_id = local.default_route_table_id
}

# 명시적 서브넷 설정
resource "aws_route_table_association" "private-subnet-az1" {
  subnet_id = aws_subnet.private-subnet-az1.id
  route_table_id = aws_vpc.toy-project-vpc.default_route_table_id
}

# 명시적 서브넷 설정
resource "aws_route_table_association" "private-subnet-az2" {
  subnet_id = aws_subnet.private-subnet-az2.id
  route_table_id = aws_vpc.toy-project-vpc.default_route_table_id
}

# # NGW2 <> Private Subnet AZ2으로 통신 되도록 Routing Table 생성 및 설정
# resource "aws_route_table" "private-rt-az2" {
#   vpc_id = aws_vpc.toy-project-vpc.id
#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_nat_gateway.ngw-az2.id
#   }
#   tags = {
#     Name = "private-rt-az2"
#   }
# }

# # NGW1 <> Private Subnet AZ1으로 통신 되도록 Routing Table 생성 및 설정
# resource "aws_route_table" "private-rt-az1" {
#   vpc_id = aws_vpc.toy-project-vpc.id
#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_nat_gateway.ngw-az1.id
#   }
#   tags = {
#     Name = "private-rt-az1"
#   }
# }

# Security Group 생성 (5ea)
# External ALB 보안 그룹 생성
resource "aws_security_group" "external-alb-sg" {
  name = "external-alb-sg"
  description = "Internet facing ALB SG"
  vpc_id = aws_vpc.toy-project-vpc.id

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

   ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress { # 보안 그룹 생성 시, Outbound 허용을 직접 지정해줘야 통신 가능(관리 콘솔은 자동 생성 / 테라폼은 지정 필수)
    from_port = 0
    to_port = 0
    protocol = "-1" # -1 == 전체 프로토콜
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "external-alb-sg"
  }
}

# Web Tier Instance 보안 그룹 생성
resource "aws_security_group" "web-tier-instance-sg" {
  name = "web-tier-instance-sg"
  description = "web instance sg"
  vpc_id = aws_vpc.toy-project-vpc.id

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

    ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    security_groups = [aws_security_group.external-alb-sg.id]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress { # 보안 그룹 생성 시, Outbound 허용을 직접 지정해줘야 통신 가능(관리 콘솔은 자동 생성 / 테라폼은 지정 필수)
    from_port = 0
    to_port = 0
    protocol = "-1" # -1 == 전체 프로토콜
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web-tier-instance-sg"
  }
}

# Internal ALB 보안 그룹 생성
resource "aws_security_group" "internal-alb-sg" {
  name = "internal-alb-sg"
  description = "Internal ALB Between Web-App"
  vpc_id = aws_vpc.toy-project-vpc.id

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    security_groups = [aws_security_group.web-tier-instance-sg.id]
    # web-tier-instance-sg에서 인바운드 되는 트래픽 허용
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress { # 보안 그룹 생성 시, Outbound 허용을 직접 지정해줘야 통신 가능(관리 콘솔은 자동 생성 / 테라폼은 지정 필수)
    from_port = 0
    to_port = 0
    protocol = "-1" # -1 == 전체 프로토콜
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "internal-alb-sg"
  }
}

# Private Instance(App Instance) 보안 그룹 생성
resource "aws_security_group" "private-instance-sg" {
  name = "private-instance-sg"
  description = "App tier instance sg"
  vpc_id = aws_vpc.toy-project-vpc.id

  ingress {
    from_port = 4000
    to_port = 4000
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 4000
    to_port = 4000
    protocol = "tcp"
    security_groups = [aws_security_group.internal-alb-sg.id]
    # 내부 ALB SG와 전체 주소 허용이 된, 4000TCP 포트로 트래픽 수신 설정
    # 해당 4000번 포트는 ALB LB Target Group Register Port로 설정 사항에 따라 변동 가능
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress { # 보안 그룹 생성 시, Outbound 허용을 직접 지정해줘야 통신 가능(관리 콘솔은 자동 생성 / 테라폼은 지정 필수)
    from_port = 0
    to_port = 0
    protocol = "-1" # -1 == 전체 프로토콜
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "private-instance-sg"
  }  
}

# DB 보안 그룹 생성
resource "aws_security_group" "db-sg" {
  name = "db-sg"
  description = "database security group"
  vpc_id = aws_vpc.toy-project-vpc.id

  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    security_groups = [aws_security_group.private-instance-sg.id]
  }

  egress { 
    from_port = 0
    to_port = 0
    protocol = "-1" # -1 == 전체 프로토콜
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "db-sg"
  }
}