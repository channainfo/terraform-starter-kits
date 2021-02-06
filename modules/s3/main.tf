resource "aws_s3_bucket" "main" {
  bucket = var.bucket_name
  acl    = "public-read"


  # direct upload
  # https://edgeguides.rubyonrails.org/active_storage_overview.html#example-s3-cors-configuration
  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["PUT", "POST", "GET"]
    # ["https://s3-website-test.hashicorp.com"]
    allowed_origins = var.sites
    expose_headers = [
      "Origin",
      "Content-Type",
      "Content-MD5",
      "Content-Disposition"
    ]
    max_age_seconds = 3600
  }

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
