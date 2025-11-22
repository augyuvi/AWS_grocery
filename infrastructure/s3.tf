#############################################
# s3.tf – S3 bucket for GroceryMate avatars
#############################################

# I create a private S3 bucket to store user avatar images for my GroceryMate app.
resource "aws_s3_bucket" "avatars" {
  bucket = "grocerymate-avatars-nithyasri2025"  # this name stay globally unique

  # I tag the bucket so I can easily identify it in the AWS console.
  tags = {
    Name        = "grocerymate-avatars-nithyasri2025"
    Environment = "Dev"
  }
}

# I enable versioning on my avatar bucket so I can keep older versions of files if needed.
resource "aws_s3_bucket_versioning" "avatars_versioning" {
  bucket = aws_s3_bucket.avatars.id

  versioning_configuration {
    status = "Enabled"
  }
}
