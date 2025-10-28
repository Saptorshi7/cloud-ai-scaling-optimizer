# --- S3 bucket for Lambda zip (optional if using local file)
resource "aws_s3_bucket" "lambda_bucket" {
  bucket = "cloud-ai-scaling-optimizer-lambda"
  force_destroy = true
}

# --- IAM Role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = "lambda-cloudwatch-role"

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

# --- Attach basic Lambda and CloudWatch policies
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_cloudwatch" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchFullAccess"
}

# --- Package Lambda zip
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file  = "${path.module}/fetch_and_publish.py"
  output_path = "${path.module}/lambda.zip"
}

# --- Lambda Function
resource "aws_lambda_function" "fetch_and_publish" {
  function_name = "fetch-and-publish-cpu"
  filename      = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  handler       = "fetch_and_publish.lambda_handler"
  runtime       = "python3.9"
  role          = aws_iam_role.lambda_role.arn
  timeout       = 60

  environment {
    variables = {
      INSTANCE_ID = "i-0123456789abcdef0"
      NAMESPACE   = "PredictiveScaling"
      METRIC_NAME = "SmoothedCPUUtilization"
    }
  }
}

# --- Schedule Lambda (runs every 5 min)
resource "aws_cloudwatch_event_rule" "schedule" {
  name                = "lambda-schedule-5min"
  schedule_expression = "rate(5 minutes)"
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.schedule.name
  target_id = "lambda"
  arn       = aws_lambda_function.fetch_and_publish.arn
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.fetch_and_publish.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.schedule.arn
}
