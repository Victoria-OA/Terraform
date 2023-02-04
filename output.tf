#output "vic_ip" {
 # value = aws_instance.vic_ec2.public_ip


#export ip
output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.vic_ec2.public_ip
}