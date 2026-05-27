variable "aws_region" {
  default = "us-east-1"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "ami_id" {
  default = "ami-0c02fb55956c7d316"
}

variable "key_name" {
  default = "project-key"
}

variable "db_username" {
  default = "postgres"
}

variable "db_password" {
  sensitive = true
}

variable "alert_email" {
  type = string
}

variable "bucket_name" {
  default = "project-app-bucket-12345"
}
