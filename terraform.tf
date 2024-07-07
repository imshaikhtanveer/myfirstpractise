terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.55.0"
    }
  }
}

provider "aws" {
  region = var.myregion
}

#VPC

  resource "aws_vpc" "main" {
  cidr_block = var.mycidr
  tags = {
    Name = "myfirstvpc"
  }
}


#Public subnet
resource "aws_subnet" "Public_Subnet" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.publicsubnet

  tags = {
    Name = "Public_Subnet"
  }
}

#Private subnet
resource "aws_subnet" "Private_Subnet" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "50.0.1.0/24"

  tags = {
    Name = "Private_Subnet"
  }
}

#IGW

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "myIGW"
  }
}

#Route Table

#MRT
resource "aws_route_table" "mrt" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "MRT"
  }

}

#Public subnet associate to MRT
resource "aws_route_table_association" "public_subnet_association" {
  subnet_id     = aws_subnet.Public_Subnet.id
  route_table_id = aws_route_table.mrt.id
}


#CRT
resource "aws_route_table" "crt" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "CRT"
  }
}

#Private subnet associate to CRT
resource "aws_route_table_association" "private_subnet_association" {
  subnet_id      = aws_subnet.Private_Subnet.id
  route_table_id = aws_route_table.crt.id
}

/*
resource "aws_eip" "eip" {
  subnet_id   = aws_subnet.Private_Subnet.id
  domain   = "vpc"
}

resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.Public_Subnet.id

  tags = {
    Name = "NAT"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.gw]
}*/

 resource "aws_instance" "this" {
  ami = "ami-04f8d7ed2f1a54b14"
  instance_type = "t2.micro"
  
  tags = {
    Name = "machine-2"
  }
}

resource "aws_key_pair" "TF_key" {
  key_name   = "TF_key"
  public_key = tls_private_key.rsa.public_key_openssh
}

resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "TF-key" {
    content  = tls_private_key.rsa.private_key_pem
    filename = "tfkey"
}

//output
output "ec2public" {
  value = aws_instance.this.public_ip
  
