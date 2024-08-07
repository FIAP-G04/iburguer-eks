resource "aws_sqs_queue" "sh_queue" {
  name                       = var.queue
  visibility_timeout_seconds = 30
}

data "aws_iam_policy_document" "sh_sqs_policy" {
  statement {
    sid    = "${var.name}-shsqsstatement" 
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "sqs:SendMessage",
      "sqs:ReceiveMessage"
    ]
    resources = [aws_sqs_queue.sh_queue.arn]
    
  }
}

resource "aws_sqs_queue_policy" "sh_sqs_policy" {
  queue_url = aws_sqs_queue.sh_queue.id
  policy    = data.aws_iam_policy_document.sh_sqs_policy.json
}