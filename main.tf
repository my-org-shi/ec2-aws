provider "aws" {
  region     = "us-east-1"
}

resource "aws_instance" "web" {
  ami           = "ami-0c7af5fe939f2677f" 
  instance_type = "t2.micro"

  tags = {
    Name = "GitHub-CI-CD-VM"
  }
}

output "instance_public_ip" {
  value = aws_instance.web.public_ip
}
