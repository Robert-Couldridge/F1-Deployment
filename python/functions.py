import logging

import boto3

logger = logging.getLogger()
logger.setLevel(logging.INFO)

dynamodb = boto3.resource("dynamodb")
tyre_wear_table = dynamodb.Table("Tyre-Wear-Table")


def predict_overtake(body: dict):

    # time difference (in seconds) between cars
    time_difference_between_cars = body["time_difference_between_cars"]

    # metrics about each car
    leading_car = body["leading_car"]
    trailing_car = body["trailing_car"]

    # predict overtake before simiulating tyre wear
    laps_till_overtake_before_tyre_wear_simulation = predict_laps_till_overtake(
        leading_car=leading_car,
        trailing_car=trailing_car,
        time_difference_between_cars=time_difference_between_cars,
    )

    if not laps_till_overtake_before_tyre_wear_simulation:
        return None

    logger.info(
        "Laps till overtake before tyre wear simulation %i",
        laps_till_overtake_before_tyre_wear_simulation,
    )

    # predict overtake whilst simulating tyre wear
    laps_till_overtake_after_tyre_wear_simulation = simulate_tyre_wear(
        laps_till_overtake_before_tyre_wear_simulation=laps_till_overtake_before_tyre_wear_simulation,
        leading_car=leading_car,
        trailing_car=trailing_car,
        time_difference_between_cars=time_difference_between_cars,
    )

    if not laps_till_overtake_after_tyre_wear_simulation:
        return None

    logger.info(
        "Laps till overtake after tyre wear simulation %i",
        laps_till_overtake_after_tyre_wear_simulation,
    )

    return {
        "laps_till_overtake": laps_till_overtake_after_tyre_wear_simulation,
        "leading_driver": leading_car["driver_name"],
        "trailing_driver": trailing_car["driver_name"],
    }


def simulate_tyre_wear(
    laps_till_overtake_before_tyre_wear_simulation: int,
    time_difference_between_cars: int,
    leading_car: dict,
    trailing_car: dict,
):
    for i in range(1, laps_till_overtake_before_tyre_wear_simulation + 1):

        # calculate leading car tyre wear
        response = tyre_wear_table.get_item(
            Key={
                "lap": leading_car["number_of_laps_on_tyres"] + i,
            }
        )
        item = response.get("Item", {})
        time_loss_due_to_tyre_wear = int(
            item.get(leading_car["tyre_compound"], "Tyre Compound Not Found")
        )
        leading_car["last_5_laptimes"].append(
            leading_car["average_lap_time"] + time_loss_due_to_tyre_wear
        )

        # calculate trailing car tyre wear
        response = tyre_wear_table.get_item(
            Key={
                "lap": trailing_car["number_of_laps_on_tyres"] + i,
            }
        )
        item = response.get("Item", {})
        time_loss_due_to_tyre_wear = int(
            item.get(trailing_car["tyre_compound"], "Tyre Compound Not Found")
        )
        trailing_car["last_5_laptimes"].append(
            trailing_car["average_lap_time"] + time_loss_due_to_tyre_wear
        )

    laps_till_overtake_after_tyre_wear_simulation = predict_laps_till_overtake(
        leading_car=leading_car,
        trailing_car=trailing_car,
        time_difference_between_cars=time_difference_between_cars,
    )

    logger.info(
        "Laps till overtake during tyre wear simulation %i",
        laps_till_overtake_after_tyre_wear_simulation,
    )

    if (
        laps_till_overtake_before_tyre_wear_simulation
        == laps_till_overtake_after_tyre_wear_simulation
    ):
        return laps_till_overtake_after_tyre_wear_simulation

    if not laps_till_overtake_after_tyre_wear_simulation:
        return None

    return simulate_tyre_wear(
        laps_till_overtake_before_tyre_wear_simulation=laps_till_overtake_after_tyre_wear_simulation,
        leading_car=leading_car,
        trailing_car=trailing_car,
        time_difference_between_cars=time_difference_between_cars,
    )


def predict_laps_till_overtake(
    leading_car: dict,
    trailing_car: dict,
    time_difference_between_cars: int,
):
    leading_car["average_lap_time"] = int(
        sum(leading_car["last_5_laptimes"]) / len(leading_car["last_5_laptimes"])
    )
    trailing_car["average_lap_time"] = int(
        sum(trailing_car["last_5_laptimes"]) / len(trailing_car["last_5_laptimes"])
    )
    average_time_gain_per_lap = (
        leading_car["average_lap_time"] - trailing_car["average_lap_time"]
    )
    if average_time_gain_per_lap <= 0:
        return None
    return int((time_difference_between_cars / average_time_gain_per_lap))
