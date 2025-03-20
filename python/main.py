import json
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)


def lambda_handler(event, context):
    logger.info("## Input Parameters")
    prediction = predict_overtake()
    logger.info("## Prediction: %s", prediction)
    response = {"statusCode": 200, "body": f"Overtake in {prediction} laps"}
    logger.info("## Response Returned: %s", response)
    return response


def predict_overtake():
    return 5
