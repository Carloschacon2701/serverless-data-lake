output "workgroup_name" {
  value       = aws_athena_workgroup.athena_database.name
  description = "The name of the Athena workgroup"
}

output "workgroup_arn" {
  value       = aws_athena_workgroup.athena_database.arn
  description = "The ARN of the Athena workgroup"
}

output "table_name" {
  value       = aws_glue_catalog_table.MyTable.name
  description = "The name of the Athena table"
}

