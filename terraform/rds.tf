resource "aws_db_instance" "postgres" {
  engine         = "postgres"
  instance_class = "db.t3.micro"

  allocated_storage = 20

  db_name  = "application"
  username = var.db_username
  password = var.db_password

  skip_final_snapshot = true
  publicly_accessible = false

  vpc_security_group_ids = [aws_security_group.rds_sg.id]
}
