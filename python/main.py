import json
import logging

import boto3
from variables import ACCOUNTNUMBER, REGION

logger = logging.getLogger()
logger.setLevel(logging.INFO)

client = boto3.client("sns")


def lambda_handler(event, context):
    try:
        # parse incoming JSON data
        body = json.loads(event["body"]) if "body" in event else {}
        logger.info("## Input Body: %s", body)

        prediction = predict_overtake(body)
        logger.info("## Prediction: %s", prediction)

        string_prediction = (
            f'{prediction["trailing_driver"]} will overtake '
            f'{prediction["leading_driver"]} in {prediction["laps_till_overtake"]} laps'
        )

        response = {"statusCode": 200, "body": string_prediction}

        # publish to sns
        client.publish(
            TopicArn=f"arn:aws:sns:{REGION}:{ACCOUNTNUMBER}:overtake-prediction",
            Message=string_prediction,
        )

        logger.info("## Response Returned: %s", response)
        return response
    except Exception as e:
        return {"statusCode": 400, "body": json.dumps({"error": str(e)})}


def predict_overtake(body: json):

    # time difference (in seconds) between cars
    time_difference_between_cars = body["time_difference_between_cars"]

    # metrics about each car
    leading_car = body["leading_car"]
    trailing_car = body["trailing_car"]

    leading_car_average_laptime = sum(leading_car["last_5_laptimes"]) / len(
        leading_car["last_5_laptimes"]
    )
    trailing_car_average_laptime = sum(trailing_car["last_5_laptimes"]) / len(
        trailing_car["last_5_laptimes"]
    )

    average_time_gain_per_lap = (
        leading_car_average_laptime - trailing_car_average_laptime
    )
    if average_time_gain_per_lap <= 0:
        return None
    laps_till_overtake = time_difference_between_cars / average_time_gain_per_lap
    return {
        "laps_till_overtake": laps_till_overtake,
        "leading_driver": leading_car["driver_name"],
        "trailing_driver": trailing_car["driver_name"],
    }


if __name__ == "__main__":
    json_body = {
        "time_difference_between_cars": 10,
        "leading_car": {
            "driver_name": "Lewis Hamilton",
            "last_5_laptimes": [91, 91, 92, 94, 92],
            "number_of_laps_on_tyres": 34,
            "tyre_compund": "soft",
        },
        "trailing_car": {
            "driver_name": "Fernando Alonso",
            "last_5_laptimes": [90, 90, 91, 92, 90],
            "number_of_laps_on_tyres": 18,
            "tyre_compund": "hard",
        },
    }
    # print(predict_overtake(body=json_body))
