# F1 Overtake Prediction Deployment

## Usage
This Terraform codebase creates an AWS application to predict the number of laps 
till one car overtakes another

### Setup
1. Export AWS Environment Variables

    ```
    export AWS_ACCESS_KEY_ID=your_key_here
    export AWS_SECRET_ACCESS_KEY=your_secret_here
    ```
2. Initialise Terraform
    - *Make sure you're in the root directory*

    ```
    terraform init
    ```
3. Populate the `accountId`, `accessKey` and `secretKey` variables
    - In the file `terraform.tfvars` put in your account ID, You can find it by clicking in the top right corner of the AWS console

#### Useful Terraform Commands
- `terraform init` , intialises terraform, run this when you first clone the 
repo or if you change modules or backend configuration
- `terraform fmt` , auto formats your terraform files
- `terraform validate` , reviews your terraform code and points out errors
- `terraform plan` , displays what terraform is about to provision 
- `terraform apply` , displays the plan and provides the option to provision that plan
- `terraform destroy` , destroys the infrastructure created by terraform

