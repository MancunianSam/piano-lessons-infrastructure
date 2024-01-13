resource "random_password" "db_password" {
  length  = 30
  special = false
}

resource "aws_ssm_parameter" "db_password" {
  name  = "/mgmt/db/password"
  type  = "SecureString"
  value = random_password.db_password.result
}

resource "aws_ssm_parameter" "db_host" {
  name  = "/mgmt/db/host"
  type  = "SecureString"
  value = aws_db_instance.database.endpoint
}

resource "aws_db_instance" "database" {
  allocated_storage         = 20
  instance_class            = "db.t3.micro"
  engine                    = "postgres"
  engine_version            = "15.3"
  username                  = "piano"
  password                  = random_password.db_password.result
  db_name                   = "pianolessons"
  identifier                = "pianolessons"
  db_subnet_group_name      = aws_db_subnet_group.subnet_group.name
  vpc_security_group_ids    = [aws_security_group.db_security_group.id]
  multi_az                  = false
  skip_final_snapshot       = true
  final_snapshot_identifier = "final-snapshot-asdasdas"
}

resource "aws_security_group" "db_security_group" {
  name        = "db-security-group"
  description = "Security group for the database"
  vpc_id      = aws_vpc.main.id
}

resource "aws_security_group_rule" "inbound_from_ecs" {
  from_port                = 5432
  protocol                 = "tcp"
  security_group_id        = aws_security_group.db_security_group.id
  to_port                  = 5432
  type                     = "ingress"
  source_security_group_id = aws_security_group.ecs_tasks_security_group.id
}

resource "aws_security_group_rule" "inbound_from_ec2" {
  from_port                = 5432
  protocol                 = "tcp"
  security_group_id        = aws_security_group.db_security_group.id
  to_port                  = 5432
  type                     = "ingress"
  source_security_group_id = aws_security_group.instance_security_group.id
}

resource "aws_db_subnet_group" "subnet_group" {
  name       = "main"
  subnet_ids = aws_subnet.private.*.id

}
