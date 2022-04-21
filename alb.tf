####################################################
# Target Group Creation
####################################################

resource "aws_lb_target_group" "tg" {
  name        = "TargetGroup"
  port        = 80
  target_type = "instance"
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
}

####################################################
# Target Group Attachment with Instance
####################################################

resource "aws_alb_target_group_attachment" "tgattachment" {
  count            = length(aws_instance.public-ec2.*.id) == 3 ? 3 : 0
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = element(aws_instance.public-ec2.*.id, count.index)
}

####################################################
# Application Load balancer
####################################################

resource "aws_lb" "lb" {
  name               = "ALB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ec2-sg.id, ]
  subnets            = [module.vpc.subnet_public1_id, module.vpc.subnet_public2_id ]   
}



####################################################
# Listner
####################################################

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}


####################################################
# Listener Rule
####################################################

resource "aws_lb_listener_rule" "static" {
  listener_arn = aws_lb_listener.front_end.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn

  }

  condition {
    path_pattern {
      values = ["/var/www/html/index.html"]
    }
  }
}
