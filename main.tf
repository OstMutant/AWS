variable "AWS_ACCESS_KEY_ID" {
    type = "string"
}
variable "AWS_SECRET_ACCESS_KEY" {
    type = "string"
}
variable "AWS_DEFAULT_REGION" {
    type = "string"
}

provider "aws" {
  access_key = "${var.AWS_ACCESS_KEY_ID}"
  secret_key = "${var.AWS_SECRET_ACCESS_KEY}"
  region     = "${var.AWS_DEFAULT_REGION}"

}

# Variables
//variable "myregion" {}
variable "accountId" {}

# API Gateway
resource "aws_api_gateway_rest_api" "api" {
    name = "myapi"
}

resource "aws_api_gateway_resource" "resource" {
    path_part = "resource"
    parent_id = "${aws_api_gateway_rest_api.api.root_resource_id}"
    rest_api_id = "${aws_api_gateway_rest_api.api.id}"
}

resource "aws_api_gateway_method" "method" {
    rest_api_id   = "${aws_api_gateway_rest_api.api.id}"
    resource_id   = "${aws_api_gateway_resource.resource.id}"
    http_method   = "ANY"
    authorization = "NONE"
}

resource "aws_api_gateway_integration" "integration" {
    rest_api_id             = "${aws_api_gateway_rest_api.api.id}"
    resource_id             = "${aws_api_gateway_resource.resource.id}"
    http_method             = "${aws_api_gateway_method.method.http_method}"
    integration_http_method = "POST"
    type                    = "AWS_PROXY"
    uri                     = "arn:aws:apigateway:${var.AWS_DEFAULT_REGION}:lambda:path/2015-03-31/functions/${aws_lambda_function.my_lambda.arn}/invocations"
}
//
# Lambda
resource "aws_lambda_permission" "apigw_lambda" {
    statement_id  = "AllowExecutionFromAPIGateway"
    action        = "lambda:InvokeFunction"
    function_name = "${aws_lambda_function.my_lambda.arn}"
    principal     = "apigateway.amazonaws.com"

    # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
    source_arn = "arn:aws:execute-api:${var.AWS_DEFAULT_REGION}:${var.accountId}:${aws_api_gateway_rest_api.api.id}/*/*"
}

resource "aws_lambda_function" "my_lambda" {
    function_name = "my_lambda"
    handler = "org.ost.investigate.aws.hw.HelloWorldJSonGreeting::handleRequest"
    runtime = "java8"
    filename = "target/aws-1.0.0.jar"
    source_code_hash = "${base64sha256(file("target/aws-1.0.0.jar"))}"
    role = "arn:aws:iam::${var.accountId}:role/service-role/myHelloWorldRole"
}

//
//resource "aws_lambda_function" "lambda" {
//    filename         = "lambda.zip"
//    function_name    = "mylambda"
//    role             = "${aws_iam_role.role.arn}"
//    handler          = "lambda.lambda_handler"
//    runtime          = "python2.7"
//    source_code_hash = "${base64sha256(file("lambda.zip"))}"
//}
//
//# IAM
//resource "aws_iam_role" "role" {
//    name = "myrole"
//
//    assume_role_policy = <<POLICY
//{
//  "Version": "2012-10-17",
//  "Statement": [
//    {
//      "Action": "sts:AssumeRole",
//      "Principal": {
//        "Service": "lambda.amazonaws.com"
//      },
//      "Effect": "Allow",
//      "Sid": ""
//    }
//  ]
//}
//POLICY
//}

//resource "aws_api_gateway_stage" "stage" {
//    stage_name = "prod"
//    rest_api_id = "${aws_api_gateway_rest_api.api.id}"
//    deployment_id = "${aws_api_gateway_deployment.stage.id}"
//}
//

resource "aws_api_gateway_deployment" "stage" {
    depends_on = ["aws_api_gateway_integration.integration"]
    rest_api_id = "${aws_api_gateway_rest_api.api.id}"
    stage_name = "dev"
}


resource "aws_api_gateway_method" "stage" {
    rest_api_id   = "${aws_api_gateway_rest_api.api.id}"
    resource_id   = "${aws_api_gateway_resource.resource.id}"
    http_method   = "GET"
    authorization = "NONE"
}

resource "aws_api_gateway_method_settings" "s" {
    rest_api_id = "${aws_api_gateway_rest_api.api.id}"
    stage_name  = "${aws_api_gateway_deployment.stage.stage_name}"
    method_path = "${aws_api_gateway_resource.resource.path_part}/${aws_api_gateway_method.stage.http_method}"

    settings {
        metrics_enabled = true
        logging_level = "INFO"
    }
}
