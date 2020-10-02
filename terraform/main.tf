provider "aws" {
  version = "~> 3.0"
  region  = var.aws_region
}


module "data" {
  source = "./data"
}

module "network" {
  vpc_id        = var.vpc_id
  igw_id        = var.igw_id
  vpc_parameter = var.vpc_parameter
  hosted_domain = var.hosted_domain
  domain_prefix = var.domain_prefix
  kibana_ip     = module.instances.kibana_ip
  source        = "./network"
}

module "security" {
  vpc_id = var.vpc_id
  source = "./security"
}

module "instances" {
  elasticsearch_count = var.elasticsearch_count
  ami_id              = module.data.ami_id
  key_name            = var.key_name
  instance_type       = var.instance_type
  vpc_parameter       = var.vpc_parameter
  public_subnet_ids   = module.network.public_subnet_ids
  private_subnet_ids  = module.network.private_subnet_ids
  bastion_sg_id       = module.security.bastion_sg
  kibana_sg_id        = module.security.kibana_sg
  elasticsearch_sg_id = module.security.elasticsearch_sg
  logstash_sg_id      = module.security.logstash_sg
  source              = "./instances"
}
