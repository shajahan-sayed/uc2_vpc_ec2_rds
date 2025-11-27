#creating vpc with 2 subntes

resource "aws_vpc" "vpc_rds" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "vpc_rds" 
  }
}
# creating subnets (public and private)
resource "aws_subnet" "public" {
  cidr_block = var.pub_cidr
  vpc_id = aws_vpc.vpc_rds.id

  tags = {
    Name = "public"
  }

resoure "aws_subnet" "private" {
   cidr_block = var.private_cidr
   vpc_id = aws_vpc.vpc_rds.id

   tags = {
     Name = "private"
   }
 }

 resource "aws_internet_gateway" "igw4" {
   vpc_id = aws_vpc.vpc_rds.id
   destination_cidr_block = "0.0.0.0/0"

   tags = {
     Name = "igw4"
   }
 }

resource "aws_nat_gateway" "nat1" {
   vpc_id = aws_vpc.vpc_rds.id
}

resource "aws_route_table" "rds_route" {
  vpc_id = aws_vpc.vpc_rds.id
  subnet_id = aws_subnet.public.id

  tags = { 
    Name = "rds_route"
  }
}

resource "aws_route_table_association" "rd_tab" {
   vpc_id = aws_vpc.vpc_rds.id
   gateway_id = aws_internet_gateway.igw4.id
   subnet_id = aws_subnet.public.id 

   tags = {
     Name = "rd_tab"
  }
}

resource "aws_route" "rds_r" {
  gateway_id = aws_internet_gateway.igw4.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_security_groug" "rds_sg" {
  vpc_id = aws_vpc.vpc_rds.id 

  ingress {
    description = "allow ssh"
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "allow http"
    from_port = 80
    to_port =80
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
   description = "allow all outbound"
   from_port = 0
   to_port = 0
   protocol = "-1"
   cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds_sg"
  }
}

resource "aws_instance" "rds-ec2" {
  ami = var.ami_id
  instance_type = var.instance_type
  key_name = var.key_name
  subnet_id = aws_subnet.public.id
  aws_security_group_ids = [aws_security_group_id.rds_sg.id]

  tags = {
    Name = "rds-ec2"
  }
}
