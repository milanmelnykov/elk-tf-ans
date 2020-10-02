output "kibana_ip" {
  value = aws_eip.kibana.public_ip
}
