# ABZ Test Assignment

This Terraform project automates the deployment of a WordPress environment, handling all necessary infrastructure provisioning, dependencies, and configurations. This includes customizable user data for WordPress setup and variable configurations to tailor deployment settings.

## Prerequisites

1. **Terraform**: Ensure Terraform is installed. [Download Terraform](https://developer.hashicorp.com/terraform/downloads)
2. **AWS Cloud Provider Account**: Set up an AWS user account with full access to EC2, RDS, ElastiCache, and Elastic Load Balancing. Obtain your `AWS_SECRET_KEY` and `AWS_ACCESS_KEY_ID`.

## Getting Started

Clone the repository to your local machine:

```bash
git clone https://github.com/vitali-o/abz.git
cd abz
```

Set environment variables for your AWS credentials:

```bash
export TF_VAR_aws_access_key='your_aws_access_key_id'
export TF_VAR_aws_secret_key='your_aws_secret_key'
```

### Variable Configuration

1. **Default Variables**: Variables are defined in `variables.tf`, with descriptions and default values for easy testing. Sensitive data, such as passwords, must be set manually.
2. **Customizing Variables**: Override any variable using the following methods (Environment Variables should be preffered for security reasons):

   - **Command Line Override**:
   
     ```bash
     terraform apply -var="variable_name=value"
     ```

   - **`terraform.tfvars` File**: Create a `terraform.tfvars` file in the root directory to define custom values:

     ```hcl
     variable_name = "value"
     ```

   - **Environment Variables**: Prefix variables with `TF_VAR_`:

     ```bash
     export TF_VAR_variable_name=value
     ```

### Important Customization Options

For WordPress configuration, adjust the following variables as needed:

- **Database-Related Settings**:
  - RDS database name:
    ```bash
    export TF_VAR_db_name='your_db_name'
    ```
  - RDS database admin username:
    ```bash
    export TF_VAR_db_user='your_db_username'
    ```
  - RDS database admin password:
    ```bash
    export TF_VAR_db_password='your_db_password'
    ```

- **WordPress-Related Settings**:
  - WordPress admin password:
    ```bash
    export TF_VAR_wp_admin_password='your_admin_password'
    ```
  - WordPress admin email:
    ```bash
    export TF_VAR_wp_admin_email='your_admin_email'
    ```
  - Site domain name (must be owned by you):
    ```bash
    export TF_VAR_wp_site_url='your_site_domain'
    ```
  - Site title:
    ```bash
    export TF_VAR_wp_site_title='your_site_title'
    ```

- **Infrastructure Settings**:
  Customize infrastructure configurations such as VPC, subnet CIDR blocks, security group rules, and EC2 instance quantity. Adjustments can be made in `variables.tf` or overridden using the above methods.

### Running the Project

1. **Initialize** the Terraform project:

   ```bash
   terraform init
   ```

2. **Review** the execution plan:

   ```bash
   terraform plan
   ```

3. **Apply** the configuration to deploy resources:

   ```bash
   terraform apply
   ```

Confirm to proceed, and Terraform will provision the infrastructure and configure the WordPress setup automatically.

### Outputs

On successful completion, relevant output values will be displayed as specified in `outputs.tf`. Remember to:

- Save the ALB endpoint URL.
- Update your's site DNS records by pointing the CNAME (defined by `TF_VAR_wp_site_url`) to the ALB endpoint.

## Security and Best Practices

- **Sensitive Data Management**: For sensitive information, use secure storage options such as HashiCorp Vault or AWS Secrets Manager instead of directly defining values in variables or environment variables.
- **Remote State Management**: For production environments, store Terraform state remotely in an S3 bucket with state locking enabled through DynamoDB. This enhances security and prevents unauthorized changes.