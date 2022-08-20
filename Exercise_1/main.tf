terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  required_version = ">= 1.2.0"
}
provider "aws" {
  region     = "us-east-1"
}
resource "aws_instance" "Udacity1" {
  count         = "4"
  ami           = "ami-052efd3df9dad4825"
  instance_type = "t2.micro"
  tags = {
    Name = "Udacity T2"
  }
}
resource "aws_instance" "Udacity2" {
  count         = "2"
  ami           = "ami-052efd3df9dad4825"
  instance_type = "m4.large"
  tags = {
    Name = "Udacity M4"
  }
}
