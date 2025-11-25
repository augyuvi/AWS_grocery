#############################################
# results.tf – outputs I need for my app
#############################################

# I output the public IP so I can quickly connect to my EC2 instance.
output "app_server_public_ip" {
  description = "Public IP of the EC2 app server"
  value       = aws_instance.app_server.public_ip
}

# I output the full URL with port 5000 to reach my Docker/Flask app.
output "app_server_url_5000" {
  description = "URL to reach the app on port 5000"
  value       = "http://${aws_instance.app_server.public_ip}:5000"
}

# I output the RDS endpoint so I can plug it into my POSTGRES_HOST env var.
output "rds_endpoint" {
  description = "PostgreSQL RDS endpoint"
  value       = aws_db_instance.grocerymate.address
}

# I output the S3 bucket name so I can reference it in my app configuration.
output "s3_bucket_name" {
  description = "S3 bucket name for avatars"
  value       = aws_s3_bucket.avatars.bucket
}
