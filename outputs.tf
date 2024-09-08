output "Webserver-Public-IP" {
    value = [for instance in aws_instance.webserver : instance.public_ip]
}

output "ALB-DNS-Name" {
    value = aws_lb.alb.dns_name
}
