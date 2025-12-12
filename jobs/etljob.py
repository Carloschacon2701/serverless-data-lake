import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
from awsgluedq.transforms import EvaluateDataQuality
from awsglue import DynamicFrame
import re

def sparkSqlQuery(glueContext, query, mapping, transformation_ctx) -> DynamicFrame:
    for alias, frame in mapping.items():
        frame.toDF().createOrReplaceTempView(alias)
    result = spark.sql(query)
    return DynamicFrame.fromDF(result, glueContext, transformation_ctx)
args = getResolvedOptions(sys.argv, ['JOB_NAME'])
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)

# Default ruleset used by all target nodes with data quality enabled
DEFAULT_DATA_QUALITY_RULESET = """
    Rules = [
        ColumnCount > 0
    ]
"""

# Script generated for node AWS Glue Data Catalog
AWSGlueDataCatalog_node1765480605208 = glueContext.create_dynamic_frame.from_catalog(database="data-lake", table_name="raw", transformation_ctx="AWSGlueDataCatalog_node1765480605208")

# Script generated for node Filter
Filter_node1765481110363 = Filter.apply(frame=AWSGlueDataCatalog_node1765480605208, f=lambda row: (row["passenger_count"] > 0 and row["trip_distance"] > 0 and row["fare_amount"] > 0), transformation_ctx="Filter_node1765481110363")

# Script generated for node SQL Query
SqlQuery2147 = '''
SELECT 
    *,
    -- 1. Calculate Total Amount
    (fare_amount + extra + mta_tax + tip_amount + tolls_amount + improvement_surcharge + congestion_surcharge) AS total_amount,

    -- 2. Calculate Trip Duration in Minutes (Unix timestamp math)
    (cast(to_timestamp(tpep_dropoff_datetime) as long) - cast(to_timestamp(tpep_pickup_datetime) as long)) / 60 AS trip_duration_minutes,

    -- 3. Flag High Value Trips (Business Logic)
    CASE 
        WHEN (fare_amount + tip_amount) > 50 THEN 'High Value'
        ELSE 'Standard' 
    END AS trip_category,

    -- 4. Calculate Tip Percentage
    CASE 
        WHEN fare_amount > 0 THEN (tip_amount / fare_amount) * 100 
        ELSE 0 
    END AS tip_percentage
FROM taxi_data
'''
SQLQuery_node1765481202148 = sparkSqlQuery(glueContext, query = SqlQuery2147, mapping = {"taxi_data":Filter_node1765481110363}, transformation_ctx = "SQLQuery_node1765481202148")

# Script generated for node Drop Fields
DropFields_node1765481438732 = DropFields.apply(frame=SQLQuery_node1765481202148, paths=["mta_tax", "extra", "improvement_surcharge", "congestion_surcharge", "PULocationID", "DOLocationID"], transformation_ctx="DropFields_node1765481438732")

# Script generated for node Amazon S3
EvaluateDataQuality().process_rows(frame=DropFields_node1765481438732, ruleset=DEFAULT_DATA_QUALITY_RULESET, publishing_options={"dataQualityEvaluationContext": "EvaluateDataQuality_node1765478647793", "enableDataQualityResultsPublishing": True}, additional_options={"dataQualityResultsPublishing.strategy": "BEST_EFFORT", "observations.scope": "ALL"})
AmazonS3_node1765481522508 = glueContext.write_dynamic_frame.from_options(frame=DropFields_node1765481438732, connection_type="s3", format="glueparquet", connection_options={"path": "s3://etl-data-lake-foundation/processed/", "partitionKeys": []}, format_options={"compression": "snappy"}, transformation_ctx="AmazonS3_node1765481522508")

job.commit()
