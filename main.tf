/*	Terraform script to create resources	*/

provider "aws" {
  region = "eu-west-1"  # Replace with your desired AWS region
}

//Using AWS cloud

resource "aws_vpc" "demo-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "demo-vpc"
  }
}

/*	creating VPC with one private&public subnet	*/

resource "aws_subnet" "private-subnet-1" {
  vpc_id     = aws_vpc.demo-vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "eu-west-1a"
  tags = {
    Name = "private-subnet-1"
  }
}
resource "aws_subnet" "public-subnet-1" {
  vpc_id     = aws_vpc.demo-vpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "eu-west-1a"
  tags = {
    Name = "public-subnet-1"
  }
}


/*	EC2 instance in above subnet(both)		*/

resource "aws_instance" "public-instance" {
  ami           = "ami-09fd16644beea3565"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public-subnet-1.id
root_block_device {
    volume_size = 8
    volume_type = "gp2"
    delete_on_termination = true
  }

  tags = {
    #Name = "public-instance"
    purpose="Assignment"
  }

}

/*	Security group attached with above EC2 instance(database SG)	*/

resource "aws_security_group" "db-sg" {
  vpc_id = aws_vpc.demo-vpc.id
  name   = "db-sg"
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.0/24", "10.0.2.0/24"]  
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "db-sg"
  }
}

resource "aws_network_interface_sg_attachment" "db-sg_attachment" {
  security_group_id    = aws_security_group.db-sg.id
  network_interface_id = aws_instance.public-instance.primary_network_interface_id
}
