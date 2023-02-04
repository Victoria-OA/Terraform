                    #creating a vpc
resource "aws_vpc" "vic_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "vicvpc"
  }
  
}

                    #creating internet gateway
resource "aws_internet_gateway" "vic_internet_gateway" {
  vpc_id = aws_vpc.vic_vpc.id

  tags = {
    "Name" = "vic-igw"
  }

}

                    #create route table
resource "aws_route_table" "vic_public_rt" {
  vpc_id = aws_vpc.vic_vpc.id

  tags = {
    Name = "vic-public-rt"
  }

}

                    #create route
resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.vic_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.vic_internet_gateway.id

}


                    #creating a subnet
#publicsubnet1
resource "aws_subnet" "vic_public_subnet" {
  vpc_id                  = aws_vpc.vic_vpc.id
 # count = 3
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-2a"

  tags = {
    "Name" = "vic-publicsubnet1"
  }

}

#Pu.subnet2
resource "aws_subnet" "vic_public_subnet" {
  vpc_id                  = aws_vpc.vic_vpc.id
 # count = 3
  cidr_block = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-2b"

  tags = {
    "Name" = "vic-publicsubnet2"
  }

}

#Pu.subnet3

resource "aws_subnet" "vic_public_subnet" {
  vpc_id                  = aws_vpc.vic_vpc.id
  count = 3
  cidr_block = "10.0.3.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-2c"

  tags = {
    "Name" = "vic-publicsubnet3"
  }

}




                    #create route table associatiom
resource "aws_route_table_association" "vic_route_assoc" {
  subnet_id      = aws_subnet.vic_public_subnet.id
  route_table_id = aws_route_table.vic_public_rt.id
}

resource "aws_route_table_association" "vic_route_assoc" {
  subnet_id      = aws_subnet.vic_public_subnet2.id
  route_table_id = aws_route_table.vic_public_rt.id
}

resource "aws_route_table_association" "vic_route_assoc" {
  subnet_id      = aws_subnet.vic_public_subnet3.id
  route_table_id = aws_route_table.vic_public_rt.id
}


                    #create security group
resource "aws_security_group" "vic_sg" {
  name        = "vic_sgp"
  description = "vic security group"
  vpc_id      = aws_vpc.vic_vpc.id
  #subnet_ids = [aws_subnet.vic_public_subnet1.id, aws_subnet.vic_public_subnet2.id]

#incoming traffic
  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "TLS from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "TLS from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

#outgoing traffic
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
   # ipv6_cidr_blocks = ["::/0"]
  }
  tags = {
    "Name" = "vic_sgp"
  }
}

                  #create keypair
resource "aws_key_pair" "vic_key" {
  key_name   = "vickey"
  public_key = file("~/.ssh/vickey.pub")
}

                    #create ec2 instances
#ec2.1
resource "aws_instance" "vic_ec2" {
  instance_type          = "t2.micro"
  ami                    = data.aws_ami.vic_ami.id
 # count                = 3
  key_name               = aws_key_pair.vic_key.id
  vpc_security_group_ids = [aws_security_group.vic_sg.id]
  subnet_id              = aws_subnet.vic_public_subnet.id
 # user_data              = file("userdata.tpl")
  root_block_device {
    volume_size = 10
  }

  tags = {
    "Name" = "vic_ec21"
  }
}

#ec2.2
  resource "aws_instance" "vic_ec2" {
  instance_type          = "t2.micro"
  ami                    = data.aws_ami.vic_ami.id
 # count                = 3
  key_name               = aws_key_pair.vic_key.id
  vpc_security_group_ids = [aws_security_group.vic_sg.id]
  subnet_id              = aws_subnet.vic_public_subnet2.id
#  user_data              = file("userdata.tpl")
  root_block_device {
    volume_size = 10
  }

  tags = {
    "Name" = "vic_ec22"
  }
  }

#ec2.3
resource "aws_instance" "vic_ec2" {
  instance_type          = "t2.micro"
  ami                    = data.aws_ami.vic_ami.id
 # count                = 3
  key_name               = aws_key_pair.vic_key.id
  vpc_security_group_ids = [aws_security_group.vic_sg.id]
  subnet_id              = aws_subnet.vic_public_subnet3.id
 # user_data              = file("userdata.tpl")
  root_block_device {
    volume_size = 10
  }
}

  tags = {
    "Name" = "vic_ec23"
  }


                    #create elastic load balancer
resource "aws_elb" "vic_elb" {
  name               = "vic-elb"
  availability_zones = ["us-east-2a, us-east-2b"]
  security_groups = ["default"]
  subnets = [aws_subnet.vic_public_subnet.id, aws_subnet.vic_public_subnet2.id]
  
  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

   health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:8000/"
    interval            = 30
  }
 # instances                   = [aws_instance.vic_vpc.id] 
  #cross_zone_load_balancing   = true
  #idle_timeout                = 400

 # tags = {
  #  Name = "vic-elb"
  #}

#}

                    #target group
resource "aws_lb_target_group" "vic_tg" {
  name     = "vic_tg"
  target_type = "instance"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vic_vpc.id
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

}

                    #route53 zone
resource "aws_route53_zone" "primary" {
  name = "victoriaakinyemi.me"
}

resource "aws_route53_record" "vic_r53" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "www.victoriaakinyemi.me"
  type    = "A"
  ttl     = 300
  records = [aws_eip.vic_elb.public_ip]
}

alias {
    name                   = aws_elb.vic_elb.dns_name
    zone_id                = aws_elb.vic_elb.zone_id
    evaluate_target_health = true
  }


              #run locally
provisioner "local-exec" {
    command = "ansible-playbook -i host-inventory site.yml"
   #   hostname     = self.public_ip,
    #  user         = "ubuntu"
     # Identityfile = "~/.ssh/vickey"
    #})
    #interpreter = ["bash", "-c"]
 # }

}

#output "instance_ips" {
 # value = join(", ", aws_instance.example.*.public_ip)
#}

#locals {
 # instance_ips = join(", ", aws_instance.example.*.public_ip)
#}

#resource "local_file" "host_inventory" {
 # content  = local.instance_ips
  #filename = "host-inventory"
#}