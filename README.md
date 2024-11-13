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
  Customize infrastructure configurations such as VPC, subnet CIDR blocks (and quantity), security group rules, and EC2 instance quantity. Adjustments can be made in `variables.tf` or overridden using the above methods.

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

**-------------------------------------------------------------------------**

## Project Structure

### Files and Their Purposes

1. **`provider.tf`**
   - Sets up the AWS provider with access credentials and a region. This file is critical to establish a connection between Terraform and AWS.

2. **`variables.tf`**
   - Defines the variables used across the project for AWS keys, VPC CIDR blocks, subnets, ingress ports, EC2 instance count, RDS database settings, and WordPress-specific configuration such as site URL and admin credentials.

3. **`network.tf`**
   - Sets up the Virtual Private Cloud (VPC) and associated networking components, including:
     - VPC with DNS support enabled.
     - Public and private subnets with dynamically assigned availability zones.
     - Internet Gateway for public access and a NAT Gateway for private subnets.
     - Route tables for routing traffic in the public and private subnets.

4. **`security.tf`**
   - Defines security groups for each component:
     - **ALB Security Group:** Allows HTTP and HTTPS traffic.
     - **EC2 Security Group:** Allows HTTP and HTTPS traffic.
     - **RDS Security Group:** Restricts MySQL access to EC2 instances.
     - **Redis Security Group:** Restricts Redis access to EC2 instances.

5. **`compute.tf`**
   - Manages the EC2 instances running the WordPress application:
     - Searches for an Amazon Linux AMI and configures each instance in a private subnet.
     - Uses a template file (`wordpress_setup.sh.tpl`) as user data to configure WordPress on launch, setting up the Apache server, installing WordPress, and configuring Redis cache.

6. **`database.tf`**
   - Configures the RDS instance for WordPress:
     - Sets up a MySQL database in a private subnet, with configurations based on variables for sensitive information like username and password.
     - Creates a DB subnet group to specify subnet placement for high availability.

7. **`cache.tf`**
   - Sets up the Redis cache with ElastiCache:
     - Defines a Redis ElastiCache cluster in private subnets for caching WordPress data, improving performance and reducing database load.
     - Includes a subnet group for ElastiCache to allow private network access within the VPC.

8. **`loadbalancer.tf`**
   - Manages the Application Load Balancer (ALB) for distributing incoming traffic across EC2 instances:
     - ALB listener listens on port 80 and forwards traffic to EC2 target instances.
     - Configures target groups and health checks to ensure that only healthy instances receive traffic.

9. **`outputs.tf`**
   - Outputs the essential infrastructure details:
     - VPC ID, RDS endpoint, Redis endpoint and port, ALB DNS name, and EC2 instance IDs.

10. **`wordpress_setup.sh.tpl`**
    - A shell script template used for EC2 instance initialization to set up WordPress:
      - Updates system packages, installs necessary dependencies, sets permissions, and deploys WordPress using WP-CLI.
      - Configures Redis as a caching layer by installing the Redis Cache plugin for WordPress.
      - Installs `wp-config.php` settings using a template with database and cache connection details.
11. **`wp-config.php.tpl`**
    - A template for wp-config.php WordPress main configuration file:
      - using this file is not necessary and required by this test assignment. WP configuration can be done by wp-cli