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