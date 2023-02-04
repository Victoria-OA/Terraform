variable "host_os" {
  type    = string
  default = "linux"
}

#export ip
variable "instance_name" {
  description = "Value of the Name tag for the EC2 instance"
  type        = string
  default     = "vic_ec2"
}

#variable "cidr_block" {
  #type = string
 # default = "10.0.0.0/16" 
#}

#variable "subnet" {
 # type = map
 # default = 
  
#}