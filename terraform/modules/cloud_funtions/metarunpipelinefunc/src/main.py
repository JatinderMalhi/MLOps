import functions_framework
from google.cloud import storage, bigquery, aiplatform
import os
import logging
gcs_client = storage.Client()
bq_client = bigquery.Client()
project_id = os.getenv("PROJECT_ID", "")
location = os.getenv("LOCATION", "")
bucket_uri = os.getenv("BUCKET_URI", "")
service_account = os.getenv("SERVICE_ACCOUNT", "")


@functions_framework.http
def run_pipeline(request):
    request_json = request.get_json(silent=True)
    logging.info("Request received: %s", request_json)
    logging.info("Initialising Vertex AI and running the pipeline job")
    aiplatform.init(project=project_id, location=location)
    TRAIN_DISPLAY_NAME = "training_meta_stock_prediction_model"
    pipeline_json_path = "data_pipeline.json"
    job = aiplatform.PipelineJob(
        display_name=TRAIN_DISPLAY_NAME,
        template_path=f"{bucket_uri}/compile_file_meta_training_model/{pipeline_json_path}",
        # template_path=pipeline_json_path,
        pipeline_root=os.path.join(bucket_uri, TRAIN_DISPLAY_NAME),
        enable_caching=False,
    )
    job.run(service_account=service_account)
    logging.info("Pipeline job submitted successfully")
