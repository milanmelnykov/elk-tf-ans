variable "ami_id" {
  default = ""
}

variable "key_name" {
  default = ""
}

variable "instance_type" {
  default = ""
}

variable "elasticsearch_count" {
  default = 0
}

variable "bastion_sg_id" {
  default = ""
}

variable "kibana_sg_id" {
  default = ""
}

variable "elasticsearch_sg_id" {
  default = ""
}

variable "logstash_sg_id" {
  default = ""
}

variable "vpc_parameter" {
  default = ""
}

variable "public_subnet_ids" {
  default = []
}

variable "private_subnet_ids" {
  default = []
}


# elastic ip for kibana istance
resource "aws_eip" "kibana" {
  instance = aws_instance.kibana.id
  vpc      = true
}

# elastic ip for bastion istance
resource "aws_eip" "bastion" {
  instance = aws_instance.bastion.id
  vpc      = true
}

# bastion instance
resource "aws_instance" "bastion" {
  ami                    = var.ami_id
  instance_type          = "t2.micro"
  key_name               = var.key_name
  vpc_security_group_ids = [var.bastion_sg_id]
  subnet_id              = element(split(",", var.public_subnet_ids), 1)

  tags = {
    Name  = "milan-bastion-ec2"
    Env   = "mibastion"
    Owner = "mmel2"
  }

  depends_on = [var.public_subnet_ids]

  lifecycle {
    create_before_destroy = true
  }
}

# kibana instance
resource "aws_instance" "kibana" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [var.kibana_sg_id]
  subnet_id              = element(split(",", var.public_subnet_ids), 0)

  tags = {
    Name  = "milan-kibana-ec2"
    Env   = "mikibana"
    Owner = "mmel2"
  }

  depends_on = [var.public_subnet_ids]

  lifecycle {
    create_before_destroy = true
  }
}

# elasticsearch instances
resource "aws_instance" "elasticsearch" {
  count                  = var.elasticsearch_count
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [var.elasticsearch_sg_id]
  subnet_id              = element(split(",", var.private_subnet_ids), count.index)

  tags = {
    Name  = "milan-elasticsearch-ec2-${count.index}"
    Env   = "mielasticsearch"
    Owner = "mmel2"
  }

  depends_on = [var.private_subnet_ids]

  lifecycle {
    create_before_destroy = true
  }
}

# logstash instances
resource "aws_instance" "logstash" {
  count                  = length(var.vpc_parameter.private_subnets)
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [var.logstash_sg_id]
  subnet_id              = element(split(",", var.private_subnet_ids), count.index)

  tags = {
    Name  = "milan-logstash-ec2-${count.index}"
    Env   = "milogstash"
    Owner = "mmel2"
  }

  depends_on = [var.private_subnet_ids]

  lifecycle {
    create_before_destroy = true
  }
}
