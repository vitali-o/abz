## Troubleshooting Tips and Common Issues

### 1. **Issue: Terraform Apply Fails Due to AWS Authentication**
   - **Cause:** Incorrect AWS Access Key and Secret Key or insufficient IAM permissions.
   - **Solution:** 
     - Verify that the access keys in `variables.tf` are correct and have the required permissions for creating VPCs, EC2 instances, RDS, ElastiCache, and ALB resources.
     - Ensure your IAM user has `AdministratorAccess` or equivalent permissions for deployment.
     - Test your credentials by running a simple AWS CLI command like `aws s3 ls`.

### 2. **Issue: VPC or Subnets Not Created Correctly**
   - **Cause:** Issues with CIDR blocks or unsupported configurations in the `network.tf` file.
   - **Solution:** 
     - Double-check CIDR blocks in `variables.tf` to ensure no overlaps between subnets.
     - Make sure subnets are correctly associated with the route tables and internet/NAT gateways.
     - Check AWS VPC limits, as you may need to increase limits on CIDR blocks or subnets.

### 3. **Issue: ALB Not Accessible or No Traffic Distribution**
   - **Cause:** ALB security group may not have the correct ingress rules, or EC2 instances might be unhealthy.
   - **Solution:** 
     - Verify that the `security.tf` file allows ALB ingress traffic on ports 80 and 443.
     - Check if the ALB health checks are correctly configured to match the EC2 service (port 80).
     - Look in the AWS console for ALB metrics under "Target Groups" to identify potential issues with instance health.

### 4. **Issue: EC2 Instances Not Connecting to RDS or Redis**
   - **Cause:** Security group settings or incorrect endpoint variables for RDS and Redis.
   - **Solution:**
     - Ensure that the RDS and Redis security groups allow inbound traffic from the EC2 security group.
     - Check `database.tf` and `cache.tf` to confirm that `db_password`, `db_user`, and Redis host variables are correctly set.
     - Confirm that `wp-config.php` includes the right database and Redis endpoint values. You may need to manually verify or update the endpoints if they change.

### 5. **Issue: WordPress Setup Fails on EC2**
   - **Cause:** Issues in the `wordpress_setup.sh.tpl` script, lack of permissions, or missing packages.
   - **Solution:**
     - Check the `cloud-init` logs on the EC2 instance (`/var/log/cloud-init-output.log`) for errors related to WordPress installation.
     - Make sure that the EC2 instance has access to the internet for downloading packages and plugins.
     - Verify that PHP, Apache, and WP-CLI are installed as expected; confirm by manually SSH’ing into the EC2 instance and running commands like `php -v` and `wp --info`.

### 6. **Issue: RDS or Redis Setup Fails**
   - **Cause:** Incorrect subnet configurations or AWS service limits.
   - **Solution:**
     - Check if your AWS account has reached the maximum number of RDS instances or ElastiCache clusters allowed.
     - Ensure that `database.tf` and `cache.tf` configurations specify subnet groups with valid subnets for each service.
     - Look at RDS or ElastiCache logs in the AWS console for detailed error messages, especially related to permissions or parameter misconfigurations.

### 7. **Issue: Timeout on Terraform Operations**
   - **Cause:** AWS resources may take longer to provision, or network connections may be slow.
   - **Solution:**
     - Increase the `timeout` settings in the Terraform configurations for resources prone to take time, such as RDS and ElastiCache.
     - Retry `terraform apply` if the error is due to transient network issues or temporary AWS service unavailability.

### 8. **Issue: Outputs Not Displayed After Apply**
   - **Cause:** Outputs not configured correctly in `outputs.tf`.
   - **Solution:**
     - Ensure all required output variables, such as ALB DNS, EC2 IDs, and RDS endpoint, are correctly defined in `outputs.tf`.
     - If an output still doesn’t appear, use `terraform output <variable_name>` to troubleshoot specific outputs directly.

### 9. **Issue: WordPress Caching Not Working**
   - **Cause:** Redis is not properly configured or connected in WordPress.
   - **Solution:**
     - SSH into the EC2 instance and check the Redis status using `redis-cli -h <Redis-endpoint> ping`.
     - Confirm that the Redis Cache plugin is active in WordPress and that Redis is enabled using the command `wp redis status` in the WordPress directory.

### 10. **Issue: WordPress Admin Login Fails**
   - **Cause:** Admin credentials not correctly set in `variables.tf`.
   - **Solution:**
     - Ensure the `wp_admin_password` and `wp_admin_email` variables in `variables.tf` match what you intend to use.
     - If needed, reset the admin password directly from the WordPress CLI on the instance: `wp user update admin --user_pass=<new_password>`.

### 11. **Issue: Timeout on Terraform Operations**
   - **Cause:** AWS resources may take longer to provision, or network connections may be slow.
   - **Solution:**
     - Increase the `timeout` settings in the Terraform configurations for resources prone to take time, such as RDS and ElastiCache.
     - Retry `terraform apply` if the error is due to transient network issues or temporary AWS service unavailability.