resource "aws_s3_bucket" "terraform_state" {
    bucket = "my-terraform-state-bucket-matan-dsfs-rwerwer"
    tags = {
    Name        = "Terraform State Bucket"
    Environment = "Production"
    }
}

resource "aws_s3_bucket_versioning" "versioning" {
    bucket = aws_s3_bucket.terraform_state.bucket

    versioning_configuration {
    status = "Enabled"
    }
}


resource "aws_s3_bucket_public_access_block" "public_access" {
    bucket = aws_s3_bucket.terraform_state.id

    block_public_acls       = true
    block_public_policy     = false
    ignore_public_acls      = true
    restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "terraform_state_policy" {
    bucket = aws_s3_bucket.terraform_state.id

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
        {
            Action    = ["s3:GetObject", "s3:PutObject"]
            Effect    = "Allow"
            Principal = {
            "AWS": "arn:aws:iam::891376965167:user/cloud_user"  # Replace with your IAM user or role ARN
            }
            Resource  = "${aws_s3_bucket.terraform_state.arn}/*"
        }
        ]
    })
}
