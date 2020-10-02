variable "vpc_id" {
  default = ""
}

variable "igw_id" {
  default = ""
}

variable "vpc_parameter" {
  default = ""
}

variable "hosted_domain" {
  default = ""
}

variable "domain_prefix" {
  default = ""
}

variable "kibana_ip" {
  default = ""
}

# public subnet (kibana here) ##################################################
resource "aws_subnet" "public" {
  vpc_id                  = var.vpc_id
  count                   = length(var.vpc_parameter.public_subnets)
  cidr_block              = lookup(var.vpc_parameter.public_subnets, count.index, "Not Found")
  availability_zone       = lookup(var.vpc_parameter.availability_zones, count.index, "Not Found")
  map_public_ip_on_launch = true

  tags = {
    Name  = format("milan-pub-elk-subnet-%d", count.index)
    Owner = "mmel2"
  }
}

# private subnet ( here)########################################################
resource "aws_subnet" "private" {
  vpc_id            = var.vpc_id
  count             = length(var.vpc_parameter.private_subnets)
  cidr_block        = lookup(var.vpc_parameter.private_subnets, count.index, "Not Found")
  availability_zone = lookup(var.vpc_parameter.availability_zones, count.index, "Not Found")

  tags = {
    Name  = format("milan-priv-elk-subnet-%d", count.index)
    Owner = "mmel2"
  }
}

# public network settings #############################
# route table
resource "aws_route_table" "public_route_table" {
  vpc_id = var.vpc_id
  tags = {
    Name = "milan-rt-for-public-subnets"
  }
}

# route mappings to igw
resource "aws_route" "public_route_for_internet_gateway" {
  route_table_id         = aws_route_table.public_route_table.id
  gateway_id             = var.igw_id
  destination_cidr_block = "0.0.0.0/0"
}

# attaching route table
resource "aws_route_table_association" "association_table_to_public_subnets" {
  count          = length(var.vpc_parameter.public_subnets)
  route_table_id = aws_route_table.public_route_table.id
  subnet_id      = element(aws_subnet.public.*.id, count.index)
}

# private web network settings #################################################
# elastic ip fot ngw
resource "aws_eip" "eip_for_nat_gateway" {
  count = length(var.vpc_parameter.private_subnets)
  vpc   = true
  tags = {
    Name = format("milan-eip-for-ngw-%d", count.index)
  }
}

# nat gateway
resource "aws_nat_gateway" "nat_gateway" {
  count         = length(var.vpc_parameter.private_subnets)
  allocation_id = element(aws_eip.eip_for_nat_gateway.*.id, count.index)
  subnet_id     = element(aws_subnet.public.*.id, count.index)

  tags = {
    Name  = format("milan-ngw-located-pub-%d", count.index)
    Owner = "mmel2"
  }
}

# route table for web private subnet  (to ngw)
resource "aws_route_table" "private_route_table" {
  count  = length(var.vpc_parameter.private_subnets)
  vpc_id = var.vpc_id
}

# route (to ngw)
resource "aws_route" "private_route_for_nat_gateway" {
  count                  = length(aws_route_table.private_route_table.*.id)
  route_table_id         = element(aws_route_table.private_route_table.*.id, count.index)
  nat_gateway_id         = element(aws_nat_gateway.nat_gateway.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"

  depends_on = [aws_nat_gateway.nat_gateway]
}

# attach route table
resource "aws_route_table_association" "association_table_to_private_subnets" {
  count          = length(var.vpc_parameter.private_subnets)
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.private_route_table.*.id, count.index)
}

# route53 record pointed to kibana's eip instance
data "aws_route53_zone" "selected" {
  name = var.hosted_domain
}

resource "aws_route53_record" "kibana" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "${var.domain_prefix}.${var.hosted_domain}"
  type    = "A"
  ttl     = "300"
  records = [var.kibana_ip]

  depends_on = [var.kibana_ip]
}
