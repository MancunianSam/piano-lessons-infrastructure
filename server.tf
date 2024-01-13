data "aws_ami" "amazon_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["al2022-ami-ecs-hvm-2022.0.20220411-x86_64-ebs"]
  }
  owners = ["591542846629"]
}

resource "aws_security_group" "alb_security_group" {
  name   = "alb-security-group"
  vpc_id = aws_vpc.main.id
}

resource "aws_security_group_rule" "alb_inbound_rule" {
  for_each          = toset(["443", "80"])
  from_port         = each.key
  protocol          = "tcp"
  security_group_id = aws_security_group.alb_security_group.id
  to_port           = each.key
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "alb_outbound_rule" {
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.alb_security_group.id
  to_port           = 0
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group" "instance_security_group" {
  name   = "piano-lessons-server-security-group"
  vpc_id = aws_vpc.main.id
}

resource "aws_security_group_rule" "ec2_outbound_postgres_rule" {
  from_port         = 5432
  protocol          = "tcp"
  security_group_id = aws_security_group.instance_security_group.id
  to_port           = 5432
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "instance_outbound_rule" {
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.instance_security_group.id
  to_port           = 443
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "instance_inbound_rule" {
  for_each                 = toset(["443", "9000"])
  from_port                = each.key
  protocol                 = "tcp"
  security_group_id        = aws_security_group.instance_security_group.id
  to_port                  = each.key
  type                     = "ingress"
  source_security_group_id = aws_security_group.alb_security_group.id
}

resource "aws_iam_role" "ec2_role" {
  name               = "EC2Role"
  assume_role_policy = templatefile("${path.module}/templates/assume_role.json.tpl", { service = "ec2" })
}

resource "aws_iam_role" "ecs_task" {
  assume_role_policy = templatefile("./templates/assume_role.json.tpl", { service = "ecs-tasks" })
  name               = "ECSTaskRole"
}

resource "aws_iam_policy" "ec2_policy" {
  policy = templatefile("./templates/ec2_policy.json.tpl", { account_number = data.aws_caller_identity.current.account_id, instance_id = aws_instance.main.id })
  name   = "EC2ServerPolicy"
}

resource "aws_iam_role_policy_attachment" "ec2_role_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.ec2_role.name
}

resource "aws_iam_role_policy_attachment" "ec2_ecs_role_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
  role       = aws_iam_role.ec2_role.name
}

resource "aws_iam_instance_profile" "instance_profile" {
  name = "ServerInstanceProfile"
  role = aws_iam_role.ec2_role.name
}

resource "aws_instance" "main" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public[0].id
  vpc_security_group_ids      = [aws_security_group.instance_security_group.id]
  iam_instance_profile        = aws_iam_instance_profile.instance_profile.id
  associate_public_ip_address = true
  user_data                   = "#!/bin/bash\necho ECS_CLUSTER=piano-lessons >> /etc/ecs/ecs.config"
}

resource "aws_alb" "alb_module" {
  name            = "piano-lessons-alb"
  subnets         = aws_subnet.public.*.id
  security_groups = [aws_security_group.alb_security_group.id]
}

resource "aws_alb_listener" "alb_module" {
  load_balancer_arn = aws_alb.alb_module.id
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = aws_acm_certificate.certificate.arn

  default_action {
    target_group_arn = aws_alb_target_group.alb_target_group.id
    type             = "forward"
  }
}

resource "aws_lb_listener" "redirect" {
  load_balancer_arn = aws_alb.alb_module.arn
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

resource "aws_alb_target_group" "alb_target_group" {
  name        = "piano-lessons-target-group"
  port        = 9000
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.main.id

  health_check {
    healthy_threshold   = "3"
    interval            = "45"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "30"
    path                = "/"
    unhealthy_threshold = 2
  }
  deregistration_delay = "0"
  tags = {
    Name = "piano-lessons-target-group"
  }
  depends_on = [aws_alb.alb_module]
}

resource "aws_ecs_cluster" "cluster" {
  name = "piano-lessons"
}


resource "aws_eip" "instance_eip" {
  instance = aws_instance.main.id
}

