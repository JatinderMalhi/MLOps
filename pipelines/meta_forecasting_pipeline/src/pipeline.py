import json
import logging
import os
import argparse
from google.cloud import bigquery, aiplatform, storage
from google_cloud_pipeline_components.v1.bigquery import (
    BigqueryCreateModelJobOp,
    BigqueryEvaluateModelJobOp,
    BigqueryForecastModelJobOp,
    BigqueryExplainForecastModelJobOp,
)
from kfp.v2 import compiler, dsl
from kfp.v2.dsl import Artifact, Condition, Input, Output, component
from config import (
    PROJECT_ID,
    SERVICE_ACCOUNT,
    DATASET_ID,
    TABLE_ID,
    LOCATION,
    BUCKET_URI,
)

PERF_THRESHOLD = 25.0
BQ_EVALUATE_MODEL_CONFIGURATION = {
    "destinationTable": {
        "projectId": PROJECT_ID,
        "datasetId": DATASET_ID,
        "tableId": "evaluation_table",
    },
    "writeDisposition": "WRITE_TRUNCATE",
}
BQ_FORECAST_CONFIGURATION = {
    "destinationTable": {
        "projectId": PROJECT_ID,
        "datasetId": DATASET_ID,
        "tableId": "forecast_table",
    },
    "writeDisposition": "WRITE_TRUNCATE",
}
BQ_EXPLAIN_FORECAST_CONFIGURATION = {
    "destinationTable": {
        "projectId": PROJECT_ID,
        "datasetId": DATASET_ID,
        "tableId": "explain_forecast_table",
    },
    "writeDisposition": "WRITE_TRUNCATE",
}


@component(base_image="python:3.10.16")
def get_evaluation_model_metrics_op(evaluation: Input[Artifact]) -> float:
    import logging

    root_mean_squared_error_value = None
    metadata = evaluation.metadata

    for row in metadata["rows"]:
        for field, value in zip(metadata["schema"]["fields"], row["f"]):
            if field["name"] == "root_mean_squared_error":
                root_mean_squared_error_value = round(float(value["v"]), 2)
                logging.info(
                    f"root_mean_squared_error: {root_mean_squared_error_value}"
                )
                break

    return root_mean_squared_error_value


@dsl.pipeline(
    name="meta-stock-training-pipeline",
    description="A pipeline to train ARIMA PLUS using BQML",
)
def pipeline(
    bq_dataset: str = DATASET_ID,
    bq_training_table: str = TABLE_ID,
    bq_evaluate_model_configuration: dict = BQ_EVALUATE_MODEL_CONFIGURATION,
    bq_forecast_configuration: dict = BQ_FORECAST_CONFIGURATION,
    bq_explain_forecast_configuration: dict = BQ_EXPLAIN_FORECAST_CONFIGURATION,
    project: str = PROJECT_ID,
    location: str = LOCATION,
):

    bq_arima_model_exp_op = BigqueryCreateModelJobOp(
        query=f"""
        -- create model table
            CREATE OR REPLACE MODEL
              `{project}.{bq_dataset}.meta_forecast_model` 
                  OPTIONS ( model_type = 'ARIMA_PLUS',
                TIME_SERIES_TIMESTAMP_COL = 'timestamp',
                TIME_SERIES_DATA_COL = 'close',
                TIME_SERIES_ID_COL = 'id',
                DATA_FREQUENCY = 'HOURLY',
                HORIZON = 168) AS ( training_data AS (
                SELECT
                  id,
                  timestamp,
                  close
                FROM
                  `{project}.{bq_dataset}.{bq_training_table}`
                WHERE
                  split = 'TRAIN' And timestamp > TIMESTAMP_SUB((SELECT MAX(timestamp) FROM `{project}.{bq_dataset}.{bq_training_table}`), INTERVAL (365 * 2) DAY)
                  ) )
        """,
        project=project,
        location=location,
    ).set_display_name("arima+ model experiment")
    logging.info("Model creation step triggered successfully")

    bq_arima_evaluate_model_op = (
        BigqueryEvaluateModelJobOp(
            project=project,
            location=location,
            model=bq_arima_model_exp_op.outputs["model"],
            query_statement=f"""
                SELECT
                  id,
                  timestamp,
                  close
                FROM
                   `{project}.{bq_dataset}.{bq_training_table}`
                WHERE
                  split = 'TEST' AND timestamp > TIMESTAMP_SUB((SELECT MAX(timestamp) FROM `{project}.{bq_dataset}.{bq_training_table}`), INTERVAL (365 * 2) DAY)
                  """,
            job_configuration_query=bq_evaluate_model_configuration,
        )
        .set_display_name("evaluate arima plus model")
        .after(bq_arima_model_exp_op)
    )
    logging.info("Evaluation started")
    root_mean_squared_error_op = get_evaluation_model_metrics_op(
        evaluation=bq_arima_evaluate_model_op.outputs["evaluation_metrics"]
    ).output
    logging.info("Root Mean Squared Error extracted")

    with Condition(
        root_mean_squared_error_op < PERF_THRESHOLD,
        name="root_mean_squared_error",
    ):
        bq_arima_model_op = BigqueryCreateModelJobOp(
            query=f"""
            -- create model table
                CREATE OR REPLACE MODEL
                  `{project}.{bq_dataset}.meta_forecast_model`  
                      OPTIONS ( model_type = 'ARIMA_PLUS',
                    TIME_SERIES_TIMESTAMP_COL = 'timestamp',
                    TIME_SERIES_DATA_COL = 'close',
                    TIME_SERIES_ID_COL = 'id',
                    DATA_FREQUENCY = 'HOURLY',
                    HORIZON = 168) AS ( training_data AS (
                    SELECT
                      id,
                      timestamp,
                      close
                    FROM
                       `{project}.{bq_dataset}.{bq_training_table}`
                    WHERE
                       timestamp > TIMESTAMP_SUB((SELECT MAX(timestamp) FROM `{project}.{bq_dataset}.{bq_training_table}`), INTERVAL (365 * 2) DAY)
                    ))
            """,
            project=project,
            location=location,
        ).set_display_name("arima plus model")
        logging.info("ARIMA+ model training started on full table")

        bq_arima_forecast_op = (
            BigqueryForecastModelJobOp(
                project=project,
                location=location,
                model=bq_arima_model_op.outputs["model"],
                horizon=168,
                confidence_level=0.9,
                job_configuration_query=bq_forecast_configuration,
            )
            .set_display_name("hourly forecast for next 7 days")
            .after(bq_arima_model_op)
        )
        logging.info("Forecasting started")

        _ = (
            BigqueryExplainForecastModelJobOp(
                project=project,
                location=location,
                model=bq_arima_model_op.outputs["model"],
                horizon=168,
                confidence_level=0.9,
                job_configuration_query=bq_explain_forecast_configuration,
            )
            .set_display_name("explain hourly forecast for next 7 days")
            .after(bq_arima_forecast_op)
        )
        logging.info("Explain forecasting started")

######
if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--compile-only", action="store_true")
    args = parser.parse_args()
    TRAIN_DISPLAY_NAME = "training_meta_stock_prediction_model"
    pipeline_json_path = "data_pipeline.json"
    logging.info("Compiling the pipeline")
    compiler.Compiler().compile(pipeline_func=pipeline, package_path=pipeline_json_path)
    logging.info("Uploading compiled pipeline to GCS")
    gcs_client = storage.Client()
    bucket = gcs_client.bucket(BUCKET_URI.replace("gs://", ""))
    blob = bucket.blob(f"compile_file_meta_training_model/{pipeline_json_path}")
    blob.upload_from_filename(pipeline_json_path)
    logging.info(f"Uploaded {pipeline_json_path} to {blob.public_url}")

    if not args.compile_only:
        logging.info("Initializing Vertex AI and running the pipeline job")
        aiplatform.init(project=PROJECT_ID, location=LOCATION)
        job = aiplatform.PipelineJob(
            display_name=TRAIN_DISPLAY_NAME,
            template_path=f"{BUCKET_URI}/compile_file_meta_training_model/{pipeline_json_path}",
            pipeline_root=os.path.join(BUCKET_URI, TRAIN_DISPLAY_NAME),
            enable_caching=False,
        )
        job.run(service_account=SERVICE_ACCOUNT)
        logging.info("Pipeline job submitted successfully")
