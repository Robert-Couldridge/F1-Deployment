import json
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)


def lambda_handler(event, context):
    try:
        # parse incoming JSON data
        body = json.loads(event["body"]) if "body" in event else {}
        logger.info("## Input Body: %s", body)

        prediction = predict_overtake(body)
        logger.info("## Prediction: %s", prediction)

        response = {"statusCode": 200, "body": f"Overtake in {prediction} laps"}
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
    return time_difference_between_cars / average_time_gain_per_lap


if __name__ == "__main__":
    json_body = {
        "time_difference_between_cars": 10,
        "leading_car": {
            "last_5_laptimes": [91, 91, 92, 94, 92],
            "number_of_laps_on_tyres": 34,
            "tyre_compund": "soft",
        },
        "trailing_car": {
            "last_5_laptimes": [90, 90, 91, 92, 90],
            "number_of_laps_on_tyres": 18,
            "tyre_compund": "hard",
        },
    }
    print(predict_overtake(body=json_body))
