################################################################ RabbitMQ ##########################################################################

# Security Group for RabbitMQ Server
resource "aws_security_group" "rabbitmq" {
  name        = "RabbitMQ"
  description = "Security Group for RabbitMQ Server"
  vpc_id      = aws_vpc.test_vpc.id

  ingress {
    from_port        = 15672
    to_port          = 15672
    protocol         = "tcp"
    security_groups  = [aws_security_group.rabbitmq_alb.id]
  }

  ingress {
    from_port        = 5672
    to_port          = 5672
    protocol         = "tcp"
    cidr_blocks      = [var.vpc_cidr]
  }

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "RabbitMQ-Server-sg"
  }
}

############################################################# RabbitMQ Server ###########################################################################

resource "aws_instance" "rabbitmq" {
  ami           = var.provide_ami
  instance_type = "t3.micro"            ###var.instance_type
  monitoring = true
  vpc_security_group_ids = [aws_security_group.rabbitmq.id]  ### var.vpc_security_group_ids       ###[aws_security_group.all_traffic.id]
  subnet_id = aws_subnet.public_subnet[0].id                   ### var.subnet_id
  root_block_device{
    volume_type="gp2"
    volume_size="20"
    encrypted=true
    kms_key_id = var.kms_key_id
    delete_on_termination=true
  }
  user_data = file("user_data_rabbitmq.sh")

  lifecycle{
    prevent_destroy=false
    ignore_changes=[ ami ]
  }

  private_dns_name_options {
    enable_resource_name_dns_a_record    = true
    enable_resource_name_dns_aaaa_record = false
    hostname_type                        = "ip-name"
  }

  metadata_options { #Enabling IMDSv2
    http_endpoint = "enabled"
    http_tokens   = "required"
    http_put_response_hop_limit = 2
  }

  tags={
    Name=var.name
    Environment = var.env
  }
}
resource "aws_eip" "eip_associate_rabbitmq" {
  domain = "vpc"     ###vpc = true
}
resource "aws_eip_association" "eip_association_rabbitmq" {  ### I will use this EC2 behind the ALB.
  instance_id   = aws_instance.rabbitmq.id
  allocation_id = aws_eip.eip_associate_rabbitmq.id
}
