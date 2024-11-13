# Application Load Balancer
resource "aws_lb" "abz_alb" {
  name               = "abz-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.abz_alb_sg.id]
  subnets            = [for subnet in aws_subnet.abz_public_subnets : subnet.id]
  tags = {
    Name = "abz-alb"
  }
}

# ALB Listener
resource "aws_lb_listener" "abz_listener" {
  load_balancer_arn = aws_lb.abz_alb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.abz_tg.arn
  }
}

# Attach instances to ALB target group
resource "aws_lb_target_group_attachment" "abz_ec2_tg_attachment" {
  for_each         = { for idx, instance in tolist(aws_instance.abz_ec2) : idx => instance }
  target_group_arn = aws_lb_target_group.abz_tg.arn
  target_id        = each.value.id
  port             = 80
}

# Target Group for ALB
resource "aws_lb_target_group" "abz_tg" {
  name     = "abz-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.abz_vpc.id
  health_check {
    path = "/"
    port = "traffic-port"
  }
  tags = {
    Name = "abz-tg"
  }
}

