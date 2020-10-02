variable "aws_region" {
  default = "us-east-1"
}

variable "vpc_id" {
  default = "vpc-0703617471eb7e67f"
}

variable "igw_id" {
  default = "igw-021b947aa9dd33038"
}

variable "hosted_domain" {
  default = "support-coe.com"
}

variable "domain_prefix" {
  default = "milan-elk"
}

variable "vpc_parameter" {
  default = {
    vpc_subnets = "172.30.0.0/16"
    public_subnets = {
      "0" = "172.30.220.0/24",
      "1" = "172.30.221.0/24"
    },
    private_subnets = {
      "0" = "172.30.222.0/24",
      "1" = "172.30.223.0/24"
    },
    availability_zones = {
      "0" = "us-east-1a",
      "1" = "us-east-1b"
    }
  }
}

variable "ssh_ip" {
  default = "109.229.29.189"
}

variable "instance_type" {
  default = "t2.small"
}

variable "key_name" {
  default = "wp-test"
}

variable "elasticsearch_count" {
  default = 3
}
