terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  required_version = ">= 1.2.0"
}
provider "aws" {
  region = var.aws_region
}
resource "random_pet" "lambda_bucket_name" {
  prefix = "learn-terraform-functions"
  length = 4
}
resource "aws_s3_bucket" "lambda_bucket" {
  bucket = random_pet.lambda_bucket_name.id
  acl           = "private"
  force_destroy = true
}
data "archive_file" "lambda_greeting" {
  type = "zip"
  source_file  = "${path.module}/greet_lambda.py"
  output_path = "${path.module}/greet_lambda.zip"
}
resource "aws_s3_object" "lambda_greeting" {
  bucket = aws_s3_bucket.lambda_bucket.id
  key    = "greet_lambda.zip"
  source = data.archive_file.lambda_greeting.output_path
  etag = filemd5(data.archive_file.lambda_greeting.output_path)
}
resource "aws_lambda_function" "greeting" {
  function_name = "CloudLabFunction"
  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_object.lambda_greeting.key
  runtime = "python3.8"
  handler = "greet_lambda.lambda_handler"
  source_code_hash = data.archive_file.lambda_greeting.output_base64sha256
  role = aws_iam_role.lambda_exec.arn
}
resource "aws_cloudwatch_log_group" "greeting" {
  name = "/aws/lambda/${aws_lambda_function.greeting.function_name}"
  retention_in_days = 30
}
resource "aws_iam_role" "lambda_exec" {
  name = "new_serverless_lambda"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
