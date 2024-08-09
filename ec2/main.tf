terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  required_version = ">= 1.2.0"
}

# 인스턴스 생성
resource "aws_instance" "toyproject_instance_1" {
  ami                    = "ami-0e6f2b2fa0ca704d0"
  instance_type          = "t2.micro"
  key_name               = data.aws_key_pair.aws5.key_name
  subnet_id              = data.aws_subnet.subnet_az1.id
  vpc_security_group_ids = [data.aws_security_group.selected.id]

  user_data = <<-EOT
                #!/bin/bash
                sudo apt update -y
                sudo apt install -y nginx
                sudo apt install -y stress
                echo "page for instance 1" > /var/www/html/index.html
                sudo systemctl start nginx
                sudo systemctl enable nginx
              EOT

  tags = {
    Name = "toyproject_instance_1"
  }
}

# resource "null_resource" "stress_service" {

 
#   provisioner "local-exec" {
#     command = <<-EOT
#       sudo tee /etc/systemd/system/stress.service <<EOF
# [Unit]
# Description=Stress Test
# After=network.target

# [Service]
# Type=simple
# ExecStart=/usr/bin/stress -c 4 -t 1200

# [Install]
# WantedBy=multi-user.target
# EOF

#       sudo systemctl daemon-reload
#       sudo systemctl restart stress
#       sudo systemctl enable stress
#     EOT
#   }
# depends_on = [aws_instance.toyproject_instance_1]

# }


# # 두 번째 인스턴스
# resource "aws_instance" "toyproject_instance_2" {
#   ami                    = "ami-0e6f2b2fa0ca704d0"
#   instance_type          = "t2.micro"
#   key_name               = data.aws_key_pair.aws5.key_name
#   subnet_id              = data.aws_subnet.subnet_az2.id
#   vpc_security_group_ids = [data.aws_security_group.selected.id]

#   user_data = <<-EOT
#                 #!/bin/bash
#                 sudo apt update -y
#                 sudo apt install -y nginx
#                 echo "page for instance 2" > /var/www/html/index.html
#                 sudo systemctl start nginx
#                 sudo systemctl enable nginx
#                 EOT

#   tags = {
#     Name = "toyproject_instance_2"
#   }
# }
