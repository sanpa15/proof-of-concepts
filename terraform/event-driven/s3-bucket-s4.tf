resource "aws_s3_bucket" "d1" {
  bucket = var.successBucket
}

resource "aws_s3_bucket" "d2" {
  bucket = var.failureBucket
}
