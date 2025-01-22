import os
from google.cloud import bigquery
import requests
from datetime import datetime
import logging

bq_client = bigquery.Client()
table_id = os.getenv("TABLE_ID", "")
api_key = os.getenv("API_KEY", "")
symbol = os.getenv("SYMBOL", "")
def get_last_fetched_timestamp():
    ######Fetch the most recent timestamp from the BigQuery table.
    try:   
        if not table_id:
            raise ValueError("TABLE_ID environment variable is not set.")

        query = f"SELECT MAX(timestamp) as last_fetched FROM `{table_id}`"
        logging.info("Executing BigQuery query: %s", query)
        result = bq_client.query(query).result()

        for row in result:
            logging.info("Last fetched timestamp: %s", row.last_fetched)
            return row.last_fetched
        logging.warning("No data found in the table.")
        return None
    except Exception as e:
        logging.error(f"Error fetching last fetched timestamp: {e}")
        return None

def insert_data_to_bigquery(rows):
    ######Insert rows into the BigQuery table.
    try:
        if not table_id:
            raise ValueError("TABLE_ID environment variable is not set.")

        if rows:
            logging.info("Inserting %d rows into BigQuery table: %s", len(rows), table_id)
            errors = bq_client.insert_rows_json(table_id, rows)
            if not errors:
                logging.info("Successfully inserted %d rows into BigQuery table %s.", len(rows), table_id)
            else:
                logging.error("Errors occurred while inserting rows: %s", errors)
                raise RuntimeError(f"BigQuery insert errors: {errors}")

        else:
            print("No data to insert into BigQuery.")
    except Exception as e:
        logging.error("Error inserting data into BigQuery: %s", e, exc_info=True)
        raise

def fetch_new_data(symbol):

    try:
        last_fetched = get_last_fetched_timestamp()
        if last_fetched:
            start_time = last_fetched
        else:
            return 
        logging.info("Fetching new data starting from: %s", start_time)
        if not api_key:
            raise ValueError("API_KEY environment variable is not set.")

        url = f"https://www.alphavantage.co/query?function=TIME_SERIES_INTRADAY&symbol={symbol}&interval=60min&apikey={api_key}"
        logging.info("Sending request to API: %s", url)
        response = requests.get(url)
        data = response.json()

        if "Time Series (60min)" in data:
            time_series = data["Time Series (60min)"]

            rows_to_insert = []
            for timestamp, values in time_series.items():
                timestamp_dt = datetime.strptime(timestamp, "%Y-%m-%d %H:%M:%S")

                if timestamp_dt > start_time:
                    rows_to_insert.append(
                        {
                            "timestamp": timestamp_dt,
                            "open": float(values["1. open"]),
                            "high": float(values["2. high"]),
                            "low": float(values["3. low"]),
                            "close": float(values["4. close"]),
                            "volume": int(values["5. volume"]),
                        }
                    )

            insert_data_to_bigquery(rows_to_insert)

            if rows_to_insert:
                logging.info("Inserted %d new rows into BigQuery.", len(rows_to_insert))
            else:
                logging.info("Data is already up-to-date. No new rows to insert.")
        else:
            logging.error("Expected data not found in API response.")
            raise KeyError("Time Series (60min) not found in API response.")
    except Exception as e:
        logging.error("Error fetching and storing data: %s", e, exc_info=True)
        raise

@functions_framework.cloud_event
def fetch_and_store_data(cloud_event):
    try:
        logging.info("Cloud Function triggered. Fetching data for symbol: %s", symbol)
        fetch_new_data(symbol)
        logging.info("Fetch and store process completed successfully.")
        return "Fetch and store process completed."
    except Exception as e:
        logging.error("Error in Cloud Function execution: %s", e, exc_info=True)
        raise
