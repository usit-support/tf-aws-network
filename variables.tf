variable "aws_region" {
  type        = string
  description = "aws region"
  default     = "us-east-1"
}

variable "project_id" {
  type        = string
  description = "project id"
}

variable "tags" {
  type        = map(string)
  description = "tags"
}