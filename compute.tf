resource "aws_key_pair" "webserver-key" {
    key_name   = var.key_name
    public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_security_group" "sg" {
    name        = "sg"
    description = "Allow TCP/80 & TCP/22"
    vpc_id      = aws_vpc.vpc.id
    ingress {
        description = "Allow SSH traffic"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        description = "Allow HTTP traffic"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_instance" "webserver" {
    count                       = 3 
    ami                         = var.ami_id
    instance_type               = "t3.micro"
    key_name                    = aws_key_pair.webserver-key.key_name
    associate_public_ip_address = true
    vpc_security_group_ids      = [aws_security_group.sg.id]
    subnet_id                   = element(aws_subnet.webserver_subnet[*].id, count.index)

    user_data = <<-EOF
                    #!/bin/bash
                    sudo yum -y install nginx
                    sudo systemctl start nginx
                    sudo systemctl enable nginx

                    # Get the hostname and local IP address
                    HOSTNAME=$(hostname)
                    LOCAL_IP=$(sudo curl http://169.254.169.254/latest/meta-data/local-ipv4)

                    # Create an index.html file with the hostname and local IP
                    echo "<h1><center>Test Website with Nginx</center></h1>" > /usr/share/nginx/html/index.html
                    echo "<p><center>Hostname: $HOSTNAME</center></p>" >> /usr/share/nginx/html/index.html
                    echo "<p><center>Local IP: $LOCAL_IP</center></p>" >> /usr/share/nginx/html/index.html
                EOF

    tags = {
        Name = "webserver-${count.index}"
    }
}
