output "iam_role_arn" {
  value = aws_iam_role.this.arn
}

output "subnets_id" {
  value = [for subnet_id in data.aws_subnet.this : subnet_id.id]
}