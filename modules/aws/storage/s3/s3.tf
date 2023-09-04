resource "aws_s3_bucket" "s3" {
  bucket        = "${var.unit}-${var.env}-${var.code}-${var.feature[0]}"
  force_destroy = var.s3_force_destroy
  tags = {
    Name    = "${var.unit}-${var.env}-${var.code}-${var.feature[0]}"
    Env     = var.env
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_s3_bucket_ownership_controls" "ownership" {
  bucket = aws_s3_bucket.s3.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "acl" {
  depends_on = [aws_s3_bucket_ownership_controls.ownership]
  bucket = aws_s3_bucket.s3.id
  acl    = var.s3_acl
}

data "aws_iam_policy_document" "allow_access_from_another_account" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::124456474132:user/iac"]
    }

    actions = [
      "s3:GetObject",
      "s3:GetBucketLocation",
      "s3:PutObject",
      "s3:ListBucket",
    ]

    resources = [
      aws_s3_bucket.s3.arn,
      "${aws_s3_bucket.s3.arn}/*",
    ]
  }
}

resource "aws_s3_bucket_policy" "allow_access_from_iac_user" {
  bucket = aws_s3_bucket.s3.id
  policy = data.aws_iam_policy_document.allow_access_from_another_account.json
}