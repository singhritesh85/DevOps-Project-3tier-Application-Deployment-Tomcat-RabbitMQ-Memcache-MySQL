# Security Group for Memcache
resource "aws_security_group" "memcache" {
  name        = "Memcache"
  description = "Security Group for Memcache"
  vpc_id      = aws_vpc.test_vpc.id

  ingress {
    from_port        = 11211
    to_port          = 11211
    protocol         = "tcp"
    cidr_blocks      = ["10.10.0.0/16"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Memcache-sg"
  }
}


resource "aws_elasticache_subnet_group" "memcache_subnetgroup" {
  name       = "threetierapp-memcache-subnetgroup"
  subnet_ids = concat("${aws_subnet.public_subnet.*.id}", "${aws_subnet.private_subnet.*.id}")
}

resource "aws_elasticache_cluster" "memcache" {
  cluster_id           = "three-tier-memcache"
  engine               = "memcached"
  engine_version       = "1.6.12"
  node_type            = "cache.t3.micro"
  num_cache_nodes      = 2
  parameter_group_name = "default.memcached1.6"
  port                 = 11211
  az_mode              = "cross-az"
  network_type         = "ipv4"
  transit_encryption_enabled = false
  subnet_group_name    = aws_elasticache_subnet_group.memcache_subnetgroup.name
  security_group_ids   = [aws_security_group.memcache.id]
#  maintenance_window   = "sun:05:00-sun:09:00"
#  notification_topic_arn = "arn:aws:sns:us-east-2:0XXXXXXXXXXX6:MyTopic"
}
