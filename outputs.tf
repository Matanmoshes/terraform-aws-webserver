output "Webserver-Public-IP" {
    value = aws_instance.webserver.public_ip
}

output "ALB-DNS-Name" {
    value = aws_lb.alb.dns_name
}
