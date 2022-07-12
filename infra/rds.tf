# + Create a PostgreSQL database in RDS. This will be used by the backend server to persist data.
# + Use 13.4 as the engine version
# + This application is very lightweight, so a “db.t3.micro” class with very little storage space should be sufficient.
# + The database should be “publicly accessible”, but make sure to still properly protect access in your security group rules
# + This database instance should be spread across multiple availability zones


resource "aws_db_subnet_group" "main" {
  name       = "main"
  subnet_ids = aws_subnet.main.*.id
}

resource "random_password" "postgres_admin_password" {
  length  = 32
  special = false
}

resource "random_password" "postgres_app_password" {
  length  = 32
  special = false
}

resource "aws_db_instance" "postgres" {
  #checkov:skip=CKV_AWS_17:Create public IP because we don't have access to private GH Actions runners
  allocated_storage    = 50
  apply_immediately    = true
  engine               = "postgres"
  engine_version       = "13.4"
  instance_class       = "db.t3.micro"
  multi_az             = true
  name                 = var.project_name
  publicly_accessible  = true
  username             = "rds_user"
  password             = random_password.postgres_admin_password.result
  db_subnet_group_name = aws_db_subnet_group.main.name

  vpc_security_group_ids = [
    aws_security_group.backend_server.id
  ]

  lifecycle {
    ignore_changes = [
      snapshot_identifier,
    ]
  }
}

