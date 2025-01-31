provider "aws" {
  region     = "us-east-1"
}

resource "aws_instance" "web" {
  ami           = "ami-04f77c9cd94746b09"  # Microsoft Windows Server 2025
  instance_type = "t2.micro"

  tags = {
    Name = "GitHub-CI-CD-VM"
  }
}

output "instance_public_ip" {
  value = aws_instance.web.public_ip
}
