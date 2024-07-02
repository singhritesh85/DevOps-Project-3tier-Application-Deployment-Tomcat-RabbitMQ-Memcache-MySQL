############################################################### Frontend-Server #####################################################################
# Security Group for Frontend-Server
resource "aws_security_group" "frontend" {
  name        = "frontend"
  description = "Security Group for Frontend Server"
  vpc_id      = aws_vpc.test_vpc.id

  ingress {
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
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
    Name = "frontend-server-sg"
  }
}

# Security Group for Backend Server
resource "aws_security_group" "backend" {
  name        = "Backend"
  description = "Security Group for Backend Server"
  vpc_id      = aws_vpc.test_vpc.id

  ingress {
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    security_groups  = [aws_security_group.frontend.id]
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
    Name = "Backend-Server-sg"
  }
}

resource "aws_instance" "frontend" {
  ami           = var.provide_ami
  instance_type = "t3.micro"    ###var.instance_type
  monitoring = true
  vpc_security_group_ids = [aws_security_group.frontend.id]      ### var.vpc_security_group_ids       ###[aws_security_group.all_traffic.id]
  subnet_id = aws_subnet.public_subnet[0].id     ###var.subnet_id
  root_block_device{
    volume_type="gp2"
    volume_size="20"
    encrypted=true
    kms_key_id = var.kms_key_id 
    delete_on_termination=true
  }
  user_data = file("user_data_frontend.sh")
         
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
    Name="Frontend-Server"
    Environment = var.env
  }
}

resource "aws_eip" "eip_associate_frontend" {
  domain = "vpc"     ###vpc = true
} 
resource "aws_eip_association" "eip_association_frontend" {  ### I will use this EC2 behind the ALB.
  instance_id   = aws_instance.frontend.id
  allocation_id = aws_eip.eip_associate_frontend.id
}

############################################################# Backend ###########################################################################

resource "aws_instance" "backend" {
  ami           = var.provide_ami
  instance_type = var.instance_type
  monitoring = true
  vpc_security_group_ids = [aws_security_group.backend.id]  ### var.vpc_security_group_ids       ###[aws_security_group.all_traffic.id]
  subnet_id = aws_subnet.public_subnet[0].id                ### var.subnet_id
  root_block_device{
    volume_type="gp2"
    volume_size="20"
    encrypted=true
    kms_key_id = var.kms_key_id
    delete_on_termination=true
  }
  user_data = file("user_data_backend.sh")

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
    Name="Backend-Server"
    Environment = var.env
  }
}
