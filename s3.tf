resource "aws_s3_bucket" "s3-bucket" {
  bucket = "rodox-s3-bucket"

  force_destroy = true

  tags = {
    Contact  = "${var.contact}"
    Project  = "${var.project}"
    Name     = "S3Bucket"
    Resource = "S3"
  }
}
