resource "aws_s3_bucket" "main" {
  bucket = var.bucket_name
  acl    = "public-read"
}

resource "aws_s3_bucket_policy" "main" {
  bucket = aws_s3_bucket.main.id

  policy = <<POLICY
{
  "Version":"2012-10-17",
  "Statement":[
    {
      "Effect": "Allow",
      "Principal": "*",
      "Action": [
        "s3:GetObject"
      ],
      "Resource": [
        "${aws_s3_bucket.main.arn}/*"
      ]
    }
  ]
}
  POLICY
}
