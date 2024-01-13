resource "aws_security_group" "ecs_tasks_security_group" {
  name        = "ecs-tasks-security-group"
  description = "Allow inbound access from the keycloak load balancer only"
  vpc_id      = aws_vpc.main.id

  tags = { "Name" = "ecs-task-security-group" }
}

resource "aws_security_group_rule" "ecs_outbound_rule" {
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.ecs_tasks_security_group.id
  to_port           = 443
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "ecs_outbound_postgres_rule" {
  from_port         = 5432
  protocol          = "tcp"
  security_group_id = aws_security_group.ecs_tasks_security_group.id
  to_port           = 5432
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "ecs_inbound_rule" {
  from_port                = 9000
  protocol                 = "tcp"
  security_group_id        = aws_security_group.ecs_tasks_security_group.id
  to_port                  = 9000
  type                     = "ingress"
  source_security_group_id = aws_security_group.alb_security_group.id
}


resource "aws_cloudwatch_log_group" "task_log_group" {
  name              = "/ecs/piano-lessons"
  retention_in_days = 30
}

resource "aws_ecr_repository" "repository" {
  name = "piano-lessons"
}

resource "aws_iam_role" "ecs_execution" {
  assume_role_policy = templatefile("./templates/assume_role.json.tpl", { service = "ecs-tasks" })
  name               = "ECSExecutionRole"
}

resource "aws_iam_policy" "ecs_execution_policy" {
  name   = "ECSExecutionPolicy"
  policy = templatefile("./templates/ecs_task_execution_policy.json.tpl", { log_group_arn = aws_cloudwatch_log_group.task_log_group.arn, repository_arn = aws_ecr_repository.repository.arn, account_number = data.aws_caller_identity.current.account_id })
}

resource "aws_iam_role_policy_attachment" "policy_attachment" {
  policy_arn = aws_iam_policy.ecs_execution_policy.arn
  role       = aws_iam_role.ecs_execution.name
}

resource "aws_iam_role_policy_attachment" "ssm_parameter_attachment" {
  policy_arn = aws_iam_policy.ecs_execution_policy.arn
  role       = aws_iam_role.ecs_execution.name
}

resource "aws_ecs_task_definition" "task" {
  container_definitions = templatefile("./templates/ecs_task.json.tpl", { account_number = data.aws_caller_identity.current.account_id })
  family                = "piano-lessons"
  execution_role_arn    = aws_iam_role.ecs_execution.arn
  task_role_arn         = aws_iam_role.ecs_task.arn
  cpu                   = 512
  memory                = 512
  network_mode          = "bridge"
}

resource "aws_ecs_service" "service" {
  name                               = "piano-lessons-service"
  cluster                            = aws_ecs_cluster.cluster.id
  task_definition                    = aws_ecs_task_definition.task.arn
  desired_count                      = 1
  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200
  launch_type                        = "EC2"


  load_balancer {
    target_group_arn = aws_alb_target_group.alb_target_group.arn
    container_name   = "piano-lessons"
    container_port   = 9000
  }
}
