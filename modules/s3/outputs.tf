output "arn" {
  value = aws_s3_bucket.main.arn
}

output "name" {
  value = var.bucket_name
}
