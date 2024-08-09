output "instance_1_public_ip" {
  description = "Public IP address of the first instance"
  value       = aws_instance.toyproject_instance_1.public_ip
}

output "instance_1_private_ip" {
  description = "Private IP address of the first instance"
  value       = aws_instance.toyproject_instance_1.private_ip
}

output "instance_1_name" {
  description = "Name tag of the first instance"
  value       = aws_instance.toyproject_instance_1.tags.Name
}

# output "instance_2_public_ip" {
#   description = "Public IP address of the second instance"
#   value       = aws_instance.toyproject_instance_2.public_ip
# }

# output "instance_2_private_ip" {
#   description = "Private IP address of the second instance"
#   value       = aws_instance.toyproject_instance_2.private_ip
# }

# output "instance_2_name" {
#   description = "Name tag of the second instance"
#   value       = aws_instance.toyproject_instance_2.tags.Name
# }
