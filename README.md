# F1 Overtake Prediction Deployment

## Usage
This Terraform codebase creates an AWS application to predict the number of laps 
till one car overtakes another

### Setup
1. Initialise Terraform
    - *Make sure you're in the root directory*

    ```
    terraform init
    ```
2. Create a `terraform.tfvars` file in the root directory and populate it with the following information
    ```
    account_id                = "<AWS ACCOUNT NUMBER>"
    lab_role                  = "<AWS ROLE ARN>"
    destination_email_address = "<EMAIL ADDRESS TO DELIVER PREDICTIONS TO>"
    ```
3. Generate and populate the `credentials` file and place it in the `.aws/` directory
4. Create a `variables.py` file in the `/python` directory and populate it with the following information
    ```
    REGION = "<AWS DEPLOYMENT REGION>"
    ACCOUNTNUMBER = "<AWS ACCOUNT NUMBER>"
    ```
5. Run `terraform apply` to build the application and generate your endpoint link
    ```
    endpoint_url = "https://u8wq4hooka.execute-api.us-east-1.amazonaws.com/dev/overtake_prediction"
    ```
6. Make a `POST` request to the provided endpoint with the body in the following JSON format
    ```
    {
        "time_difference_between_cars": 5,
        "leading_car": {
            "driver_name": "Lewis Hamilton",
            "last_5_laptimes": [91, 91, 92, 94, 92],
            "number_of_laps_on_tyres": 34,
            "tyre_compund": "soft"
        },
        "trailing_car": {
            "driver_name": "Fernando Alonso",
            "last_5_laptimes": [90, 90, 91, 92, 90],
            "number_of_laps_on_tyres": 18,
            "tyre_compund": "hard"
        }
    }
    ```

#### Useful Terraform Commands
- `terraform init` , intialises terraform, run this when you first clone the 
repo or if you change modules or backend configuration
- `terraform fmt` , auto formats your terraform files
- `terraform validate` , reviews your terraform code and points out errors
- `terraform plan` , displays what terraform is about to provision 
- `terraform apply` , displays the plan and provides the option to provision that plan
- `terraform destroy` , destroys the infrastructure created by terraform

