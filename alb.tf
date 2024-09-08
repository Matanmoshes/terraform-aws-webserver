resource "aws_lb" "alb" {
    name               = "webserver-alb"
    internal           = false
    load_balancer_type = "application"
    security_groups    = [aws_security_group.sg.id]
    subnets            = aws_subnet.webserver_subnet[*].id

    tags = {
        Name = "webserver-alb"
    }
}

resource "aws_lb_target_group" "tg" {
    name        = "webserver-tg"
    port        = 80
    protocol    = "HTTP"
    vpc_id      = aws_vpc.vpc.id
    target_type = "instance"

    health_check {
        path                = "/"
        protocol            = "HTTP"
        matcher             = "200-299"
        interval            = 30
        timeout             = 5
        healthy_threshold   = 3
        unhealthy_threshold = 2
    }
}

resource "aws_lb_listener" "listener" {
    load_balancer_arn = aws_lb.alb.arn
    port              = 80
    protocol          = "HTTP"

    default_action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.tg.arn
    }
}

resource "aws_lb_target_group_attachment" "attachment" {
    count            = 3 
    target_group_arn = aws_lb_target_group.tg.arn
    target_id        = aws_instance.webserver[count.index].id
    port             = 80
}
