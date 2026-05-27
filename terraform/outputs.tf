output "frontend_ip" {
  value = aws_instance.frontend.public_ip
}

output "backend_ip" {
  value = aws_instance.backend.public_ip
}

output "worker_ip" {
  value = aws_instance.worker.public_ip
}

output "rds_endpoint" {
  value = aws_db_instance.postgres.endpoint
}
