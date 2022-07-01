# + Create a publicly accessible S3 bucket. This will host the statically generated frontend website. The index document for the website will be index.html and the error document will be 404.html.
# + Hint: you will probably also need an S3 bucket policy for the bucket as well.
# + Also notice that a logging bucket has already been set up in S3 (see s3.tf).

resource "random_uuid" "random_id" {}

resource "aws_s3_bucket" "frontend" {
  #checkov:skip=CKV2_AWS_6:Website should be publicly accessible
  #checkov:skip=CKV_AWS_19:Don't encrypt publicly accessible website
  #checkov:skip=CKV_AWS_20:Website should be publicly accessible
  #checkov:skip=CKV_AWS_21:Versioning of websited is handled through git
  #checkov:skip=CKV_AWS_145:Don't encrypt publicly accessible website
  bucket = "frontend-${random_uuid.random_id.id}"
  force_destroy = true
}

resource "aws_s3_bucket_policy" "frontend" {
  bucket = aws_s3_bucket.frontend.bucket
  policy = data.aws_iam_policy_document.bucket_logging.json

}

data "aws_iam_policy_document" "frontend" {
    statement {
    actions = ["s3:PutObject"]
    resources = [
      "arn:aws:s3:::${aws_s3_bucket.frontend.bucket}/*/AWSLogs/${data.aws_caller_identity.current.account_id}/*",
    ]

    principals {
      type        = "AWS"
      identifiers = [data.aws_elb_service_account.main.arn]
    }
  }

  statement {
    actions = ["s3:PutObject"]
    resources = [
      "arn:aws:s3:::${aws_s3_bucket.frontend.bucket}/*/AWSLogs/${data.aws_caller_identity.current.account_id}/*",
    ]

    principals {
      type        = "Service"
      identifiers = ["delivery.frontend.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }

  statement {
    actions   = ["s3:GetBucketAcl"]
    resources = ["arn:aws:s3:::${aws_s3_bucket.frontend.bucket}"]

    principals {
      type        = "Service"
      identifiers = ["delivery.frontend.amazonaws.com"]
    }
  }
}

resource "aws_s3_bucket_public_access_block" "frontend" {
  #checkov:skip=CKV_AWS_53:Website should be publicly accessible
  #checkov:skip=CKV_AWS_54:Website should be publicly accessible
  #checkov:skip=CKV_AWS_55:Website should be publicly accessible
  #checkov:skip=CKV_AWS_56:Website should be publicly accessible
}



resource "aws_s3_bucket" "logging" {
  #checkov:skip=CKV_AWS_18:This is the logging bucket
  bucket        = "access-logs-${random_uuid.random_id.id}"
  acl           = "private"
  force_destroy = true

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_s3_bucket_public_access_block" "logging" {
  bucket = aws_s3_bucket.logging.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "bucket_logging" {
  bucket = aws_s3_bucket.logging.bucket
  policy = data.aws_iam_policy_document.bucket_logging.json
}

data "aws_elb_service_account" "main" {}


data "aws_iam_policy_document" "bucket_logging" {
  statement {
    actions = ["s3:PutObject"]
    resources = [
      "arn:aws:s3:::${aws_s3_bucket.logging.bucket}/*/AWSLogs/${data.aws_caller_identity.current.account_id}/*",
    ]

    principals {
      type        = "AWS"
      identifiers = [data.aws_elb_service_account.main.arn]
    }
  }

  statement {
    actions = ["s3:PutObject"]
    resources = [
      "arn:aws:s3:::${aws_s3_bucket.logging.bucket}/*/AWSLogs/${data.aws_caller_identity.current.account_id}/*",
    ]

    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }

  statement {
    actions   = ["s3:GetBucketAcl"]
    resources = ["arn:aws:s3:::${aws_s3_bucket.logging.bucket}"]

    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }
  }
}

