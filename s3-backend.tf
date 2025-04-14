# Create the S3 bucket
resource "aws_s3_bucket" "tf_state" {
  bucket = "kendu237backend"
  acl    = "private"  # Ensures no public access
  key    = "state/terraform_state.tfstate"
  region = "eu-north-1"

  versioning {
    enabled = true  # Critical for state recovery
  }

  # Optional: Enable encryption
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}