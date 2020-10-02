output "public_subnet_ids" {
  value = join(",", aws_subnet.public.*.id)
}

output "private_subnet_ids" {
  value = join(",", aws_subnet.private.*.id)
}


output "ngw_ips" {
  value = join(",", aws_nat_gateway.nat_gateway.*.public_ip)
}
