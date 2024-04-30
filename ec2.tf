resource "aws_security_group" "wp_sg" {
  name        = "wordpress-sg-${terraform.workspace}"
  description = "Security group for WordPress instance in ${terraform.workspace}"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
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

  tags = {
    Name = "SG-WordPress-${terraform.workspace}"
  }
}

resource "aws_instance" "wordpress" {
  for_each      = local.instance_types
  ami           = var.ami_id
  instance_type = each.value
  key_name      = var.key_name
  subnet_id     = local.subnet_ids[each.key]

  vpc_security_group_ids = [aws_security_group.wp_sg.id]

  tags = {
    Name = "WordPress-${each.key}"
  }
}

resource "aws_lb_target_group" "tg" {
  for_each = toset(["dev", "stage", "prod"])

  name     = "tg-${each.key}"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
  }

  tags = {
    Name = "TG-${each.key}"
  }
}

resource "aws_lb_target_group_attachment" "tg_attachment" {
  for_each = aws_instance.wordpress

  target_group_arn = aws_lb_target_group.tg[each.key].id
  target_id        = each.value.id
  port             = 80
}

resource "aws_lb" "wordpress_alb" {
  name               = "wordpress-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.wp_sg.id]
  subnets            = var.subnets

  tags = {
    Name = "MainALB"
  }
}

resource "aws_lb_listener" "main" {
  load_balancer_arn = aws_lb.wordpress_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "404 Not Found"
      status_code  = "404"
    }
  }
}

resource "aws_lb_listener_rule" "host_based_routing" {
  for_each = {
    "dev"   = "dev.wordpress.com"
    "stage" = "stage.wordpress.com"
    "prod"  = "wordpress.com"
  }

  listener_arn = aws_lb_listener.main.arn
  priority     = 100 + length(each.key)

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg[each.key].arn
  }

  condition {
    host_header {
      values = [each.value]
    }
  }
}

