variable "vpc_id" {
  default = ""
}


# Security Group for kibana
resource "aws_security_group" "bastion_sg" {
  name   = "bastion-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name  = "milan-bastion-sg"
    Owner = "mmel2"
  }
}


# Security Group for kibana
resource "aws_security_group" "kibana_sg" {
  name   = "kibana-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port       = 22
    to_port         = 22
    security_groups = [aws_security_group.bastion_sg.id]
    protocol        = "tcp"
  }

  dynamic "ingress" {
    for_each = ["80", "443"]
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name  = "milan-kibana-sg"
    Owner = "mmel2"
  }
}

# Security Group for elasticsearch
resource "aws_security_group" "elasticsearch_sg" {
  name   = "elasticsearch-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port       = 22
    to_port         = 22
    security_groups = [aws_security_group.bastion_sg.id]
    protocol        = "tcp"
  }

  ingress {
    from_port       = 9200
    to_port         = 9200
    security_groups = [aws_security_group.kibana_sg.id, aws_security_group.logstash_sg.id]
    protocol        = "tcp"
  }

  ingress {
    from_port = 9300
    to_port   = 9300
    self      = "true"
    protocol  = "tcp"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name  = "milan-elasticsearch-sg"
    Owner = "mmel2"
  }
}

# Security Group for logstash
resource "aws_security_group" "logstash_sg" {
  name   = "logstash-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port       = 22
    to_port         = 22
    security_groups = [aws_security_group.bastion_sg.id]
    protocol        = "tcp"
  }

  ingress {
    from_port   = 9600
    to_port     = 9600
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name  = "milan-logstash-sg"
    Owner = "mmel2"
  }
}
