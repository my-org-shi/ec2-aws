provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "web" {
  ami           = "ami-0c7af5fe939f2677f"  # RHEL 9 AMI (Ensure it's valid for us-east-1)
  instance_type = "t2.micro"  # Nitro-based instance for UEFI compatibility

  key_name      = "my-ssh-key1"  # Replace with your existing key pair name
  subnet_id     = aws_subnet.my_subnet.id  # Reference to created subnet

  vpc_security_group_ids = [aws_security_group.web_sg.id]

  tags = {
    Name = "GitHub-CI-CD-VM"
  }
}

# ✅ Security Group to Allow SSH (Port 22) & UI Access (Port 80, 443)
resource "aws_security_group" "web_sg" {
  name        = "web-instance-sg"
  description = "Allow SSH & HTTP/S access"
  vpc_id      = aws_vpc.my_vpc.id  # Attach SG to created VPC

  # Allow SSH (Port 22)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Change to your IP for security
  }

  # Allow HTTP (Port 80)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTPS (Port 443)
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ✅ Create VPC, Subnet & Internet Gateway for Network Connectivity
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "my_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }
}

resource "aws_route_table_association" "subnet_association" {
  subnet_id      = aws_subnet.my_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# ✅ Output Instance Public IP
output "instance_public_ip" {
  value = aws_instance.web.public_ip
}
