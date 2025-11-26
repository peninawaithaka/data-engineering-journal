# Provider block
provider "aws" {
  profile = "default"
  region = "us-east-1"
}

#Resources Block
resource "aws_instance" "server" {
  ami           = "ami-0fa3fe0fa7920f68e"
  instance_type = "t3.micro"

  user_data = <<-EOF
              #!/bin/bash
              # Update system packages
              sudo yum update -y
              
              # Install PostgreSQL
              sudo amazon-linux-extras install postgresql14 -y
              
              # Initialize PostgreSQL database
              sudo postgresql-setup --initdb
              
              # Start and enable PostgreSQL service
              sudo systemctl start postgresql
              sudo systemctl enable postgresql
              
              # Configure PostgreSQL to allow password authentication
              sudo sed -i 's/ident/md5/g' /var/lib/pgsql/data/pg_hba.conf
              sudo sed -i 's/peer/md5/g' /var/lib/pgsql/data/pg_hba.conf
              
              # Restart PostgreSQL to apply changes
              sudo systemctl restart postgresql
              
              # Create database and user
              sudo -u postgres psql <<-PSQL
                CREATE DATABASE analytics_db;
                CREATE USER analytics_engineer WITH ENCRYPTED PASSWORD 'ae@2025';
                GRANT ALL PRIVILEGES ON DATABASE analytics_db TO analytics_engineer;
              PSQL
              
              echo "PostgreSQL installation and setup completed"
              EOF

  tags = {
    Name = "Terraform PostgreSQL Instance"
  }
}

# Output the instance public IP
output "server_public_ip" {
  value       = aws_instance.server.public_ip
  description = "Public IP address of the server"
}