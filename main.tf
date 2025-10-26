provider "aws" {
  region = "us-east-1" 
}

# S3 Bucket
resource "aws_s3_bucket" "test_bucket" {
  bucket = "devops-test-bucket-2025" 
}

# IAM Role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = "S3ToSlackLambdaRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# Attach Basic Lambda Execution Policy
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"  # For CloudWatch logs
}

# Attach Secrets Manager Policy
resource "aws_iam_role_policy_attachment" "secrets_manager" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/SecretsManagerReadWrite"  # For Secrets Manager access
}

# Lambda Function
resource "aws_lambda_function" "notifier" {
  function_name = "s3-slack-notifier"
  handler       = "s3_slack_notifier.lambda_handler"
  runtime       = "python3.13"
  role          = aws_iam_role.lambda_role.arn
  filename      = "https://us-east-1.console.aws.amazon.com/lambda/home?region=us-east-1#/functions/s3-slack-notifier"
  source_code_hash = filebase64sha256("../lambda/s3_slack_notifier.zip")

  environment {
    variables = {
      SECRET_NAME = "slack-webhook-secret"
    }
  }
}

# Lambda Permission for S3 to Invoke
resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.notifier.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.test_bucket.arn
}

# S3 Bucket Notification
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.test_bucket.id
  lambda_function {
    lambda_function_arn = aws_lambda_function.notifier.arn
    events              = ["s3:ObjectCreated:*"]
  }
  depends_on = [aws_lambda_permission.allow_s3]
}