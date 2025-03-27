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

#### Useful Terraform Commands
- `terraform init` , intialises terraform, run this when you first clone the 
repo or if you change modules or backend configuration
- `terraform fmt` , auto formats your terraform files
- `terraform validate` , reviews your terraform code and points out errors
- `terraform plan` , displays what terraform is about to provision 
- `terraform apply` , displays the plan and provides the option to provision that plan
- `terraform destroy` , destroys the infrastructure created by terraform

