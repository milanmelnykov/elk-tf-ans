output "bastion_sg" {
  value = aws_security_group.bastion_sg.id
}

output "kibana_sg" {
  value = aws_security_group.kibana_sg.id
}

output "elasticsearch_sg" {
  value = aws_security_group.elasticsearch_sg.id
}

output "logstash_sg" {
  value = aws_security_group.logstash_sg.id
}
