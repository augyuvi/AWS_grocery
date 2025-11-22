#############################################
# main.tf – VPC, EC2 app server, RDS database
#############################################

# I look up the latest Amazon Linux 2023 AMI in my region.
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

# I create my own VPC instead of using the default one.
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-vpc"
    }
  )
}

# I attach an internet gateway so instances in the public subnet can reach the internet.
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-igw"
    }
  )
}

# This is my public subnet; my EC2 app server will live here.
resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-public-a"
    }
  )
}

# Route table to send internet traffic from the public subnet through the IGW.
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-public-rt"
    }
  )
}

resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

# Two private subnets for my RDS database (RDS subnet groups require at least two AZs).
resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.11.0/24"
  availability_zone = "${var.aws_region}a"

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-private-a"
    }
  )
}

resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.12.0/24"
  availability_zone = "${var.aws_region}b"

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-private-b"
    }
  )
}

# Security group for my EC2 application server.
resource "aws_security_group" "app_sg" {
  name        = "app_sg_${var.project_name}"
  description = "Security group for GroceryMate EC2"
  vpc_id      = aws_vpc.main.id

  # I open SSH so I can manage the instance.
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_allowed_ip]
  }

  # I open HTTP in case I want to serve traffic on port 80.
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.http_allowed_cidrs
  }

  # I expose my Flask/Docker application on port 5000.
  ingress {
    description = "App port 5000"
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = var.http_allowed_cidrs
  }

  # I allow all outbound traffic so the instance can reach the internet and RDS.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.common_tags,
    {
      Name        = "${var.project_name}-app-sg"
      Environment = var.environment
    }
  )
}

# Security group for my RDS instance; it only accepts traffic from the EC2 SG.
resource "aws_security_group" "db_sg" {
  name        = "db_sg_${var.project_name}"
  description = "Security group for GroceryMate RDS"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "PostgreSQL from app EC2"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.app_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.common_tags,
    {
      Name        = "${var.project_name}-db-sg"
      Environment = var.environment
    }
  )
}

# This is my free-tier EC2 instance that will run my GroceryMate application.
resource "aws_instance" "app_server" {
  ami                         = data.aws_ami.amazon_linux_2023.id
  instance_type               = var.instance_type
  key_name                    = var.key_pair_name
  subnet_id                   = aws_subnet.public_a.id
  vpc_security_group_ids      = [aws_security_group.app_sg.id]
  associate_public_ip_address = true

  # I install and start Docker in user_data so the instance is ready to run my container.
  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y docker
              systemctl enable docker
              systemctl start docker
              EOF

  tags = merge(
    var.common_tags,
    {
      Name        = "${var.project_name}-ec2"
      Environment = var.environment
    }
  )
}

# I define a subnet group for my PostgreSQL database using the two private subnets.
resource "aws_db_subnet_group" "grocerymate" {
  name       = "${var.project_name}-db-subnets"
  subnet_ids = [aws_subnet.private_a.id, aws_subnet.private_b.id]

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-db-subnet-group"
    }
  )
}

# This is my free-tier PostgreSQL RDS instance for GroceryMate.
resource "aws_db_instance" "grocerymate" {
  identifier             = "grocerymate-db"
  engine                 = "postgres"
  instance_class         = var.db_instance_class
  allocated_storage      = var.db_allocated_storage
  db_name                = "grocerymate_db"
  username               = var.db_username
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.grocerymate.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  skip_final_snapshot    = true
  deletion_protection    = false
  publicly_accessible    = false
  multi_az               = false

  tags = merge(
    var.common_tags,
    {
      Name        = "${var.project_name}-rds"
      Environment = var.environment
    }
  )
}
