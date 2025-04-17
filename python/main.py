import json
import logging

import boto3
from functions import predict_overtake
from variables import ACCOUNTNUMBER, REGION

logger = logging.getLogger()
logger.setLevel(logging.INFO)

sns = boto3.client("sns")


def lambda_handler(event, context):
    try:
        # parse incoming JSON data
        body = json.loads(event["body"]) if "body" in event else {}
        logger.info("## Input Body: %s", body)

        prediction = predict_overtake(body)
        logger.info("## Prediction: %s", prediction)

        if prediction:
            string_prediction = (
                f'{prediction["trailing_driver"]} will overtake '
                f'{prediction["leading_driver"]} in {prediction["laps_till_overtake"]} laps'
            )
        else:
            string_prediction = "No overtake likely"

        response = {"statusCode": 200, "body": string_prediction}

        # publish to sns
        sns.publish(
            TopicArn=f"arn:aws:sns:{REGION}:{ACCOUNTNUMBER}:overtake-prediction",
            Message=string_prediction,
        )

        logger.info("## Response Returned: %s", response)
        return response
    except Exception as e:
        return {"statusCode": 400, "body": json.dumps({"error": str(e)})}
