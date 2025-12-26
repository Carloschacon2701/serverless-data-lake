
########################################################
# Athena Workgroup
########################################################
resource "aws_athena_workgroup" "athena_database" {
  name = var.workgroup_name
  configuration {

    engine_version {
      selected_engine_version = "AUTO"
    }
    managed_query_results_configuration {
      enabled = true
    }
  }

}

########################################################
# Glue Catalog Table for Athena
########################################################
resource "aws_glue_catalog_table" "MyTable" {
  database_name = var.database_name
  name          = "athena_table"
  owner         = "hadoop"
  parameters = {
    EXTERNAL              = "TRUE"
    classification        = "parquet"
    transient_lastDdlTime = "1766355862"
  }
  region     = "us-east-1"
  table_type = "EXTERNAL_TABLE"
  storage_descriptor {
    input_format  = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat"
    location      = "s3://${var.bucket_name}"
    output_format = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat"

    dynamic "columns" {
      for_each = var.columns
      content {
        name = columns.value.name
        type = columns.value.type
      }
    }

    ser_de_info {
      parameters = {
        "serialization.format" = "1"
      }
      serialization_library = "org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe"
    }
  }
}

