# abz test assignment

This Terraform project automates the deployment of a small AWS infrastructure and automatically install latest WordPress with necessary dependencies and configurations. The setup includes infrastructure provisioning, user data customization for WordPress setup, and variable configurations to control deployment settings.

## Prerequisites

1. **Terraform**: Ensure Terraform is installed. [Install Terraform](https://developer.hashicorp.com/terraform/downloads)
2. **Cloud Provider Account**: Set up and configure credentials for the specified cloud provider in `provider.tf`.

## Getting Started

### Cloning the Repository

Clone this repository to your local machine:

```bash
git clone https://github.com/vitali-o/abz.git
cd abz
```

### Variable Configuration

1. **Default Variable Configuration**: Variables are defined in the `variables.tf` file with default values.
2. **Custom Variables**: To override any variable, you have the following options:

   - **Command Line Override**: Specify variables directly in the CLI during execution:
   
     ```bash
     terraform apply -var="variable_name=value"
     ```

   - **`terraform.tfvars` File**: Create a `terraform.tfvars` file in the root directory and define your custom values:

     ```hcl
     variable_name = "value"
     ```

   - **Environment Variables**: Set environment variables prefixed with `TF_VAR_`:

     ```bash
     export TF_VAR_variable_name=value
     ```

### Running the Project

Initialize the Terraform project:

```bash
terraform init
```

Review the execution plan:

```bash
terraform plan
```

Apply the configuration to deploy resources:

```bash
terraform apply
```

After confirming, Terraform will provision the infrastructure and configure the WordPress setup automatically.

### Outputs

Upon successful completion, relevant output values will be displayed. Output configurations are specified in `outputs.tf`.

## Customization Options

### Terraform Module Customizations

The `main.tf` file includes modules for creating infrastructure resources such as virtual machines, network settings, and security groups. You can customize these modules by modifying:

- **Module Source**: Define a different module source if needed.
- **Module Variables**: Update module input variables in `main.tf` to change aspects such as instance type, network configurations, and resource tags.

### Template Files for User Data

This project uses template files (`tpl`) for generating `user_data` scripts, specifically for WordPress installation and configuration.

- **`wordpress_setup.sh.tpl`**: This script template installs WordPress along with necessary dependencies. You can customize this template to adjust:

  - **Packages**: Add or remove packages installed during the WordPress setup.
  - **Configuration Steps**: Modify the commands and scripts for setting up WordPress, adjusting parameters as needed.

- **`wp-config.php.tpl`**: This template generates the WordPress `wp-config.php` file, including database connection settings and essential configurations.

  - **Database Settings**: Adjust database host, name, user, and password if you need different settings than those specified.
  - **Security Keys and Salts**: You can insert custom security keys for WordPress by modifying this template.

Both template files can be edited directly or made dynamic by introducing additional variables in `variables.tf` for further customization.

### Overriding Templates in Terraform

You can use Terraform’s `templatefile` function to incorporate changes into your setup without directly modifying the original `tpl` files. Define your custom template files and use them as follows in `main.tf`:

```hcl
user_data = templatefile("${path.module}/custom_wordpress_setup.sh.tpl", {
  variable_name = var.value
})
```

This allows you to maintain original templates while testing or implementing custom scripts.

---

## Additional Notes

- **Cleanup**: After finishing with the deployment, run the following command to destroy all resources:

  ```bash
  terraform destroy
  ```

- **Security**: Ensure that sensitive information such as database credentials is securely stored and not hardcoded in template files.

--- 

This `README.md` provides a comprehensive guide to getting the project up and running, customizing deployment, and extending functionality through template files.