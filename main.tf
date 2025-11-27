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
  map_public_ip_on_launch = true
  availability_zone       = var.public_az1

  tags = {
    Name = "public"
  }
}

resource "aws_subnet" "private" {
   cidr_block = var.private_cidr
   vpc_id = aws_vpc.vpc_rds.id
   availability_zone       = var.private_az1

   tags = {
     Name = "private"
   }
 }
resource "aws_subnet" "private2" {
  cidr_block = var.private2_cidr
  vpc_id = aws_vpc.vpc_rds.id
  availability_zone = var.private2_az2

  tags = {
    Name = "private2"
   }
}

 resource "aws_internet_gateway" "igw4" {
   vpc_id = aws_vpc.vpc_rds.id

   tags = {
     Name = "igw4"
   }
 }

resource "aws_route_table" "rds_route" {
  vpc_id = aws_vpc.vpc_rds.id

  tags = { 
    Name = "rds_route"
  }
}

resource "aws_route_table_association" "public" {
   subnet_id = aws_subnet.public.id 
   route_table_id = aws_route_table.rds_route.id
}

resource "aws_route" "rds_r" {
  gateway_id = aws_internet_gateway.igw4.id
  destination_cidr_block = "0.0.0.0/0"
  route_table_id = aws_route_table.rds_route.id
}

resource "aws_security_group" "ec2_sg1" {
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
  vpc_security_group_ids = [aws_security_group.ec2_sg1.id]

  tags = {
    Name = "rds-ec2"
  }
}

resource "aws_security_group" "rds_sg" {
  description = "allow mysql port"
  vpc_id = aws_vpc.vpc_rds.id

  ingress {
    description = "allowing port 3306"
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
 }

#creating rds instance

resource "aws_db_subnet_group" "main-subnet" {
  name = "main_subnet"
  subnet_ids = [
          aws_subnet.private.id,
          aws_subnet.private2.id
  ]

  tags = {
    Name = "main-subnet"
  }
}

resource "aws_db_instance" "mysql" {
  allocated_storage = 20
  engine = "mysql"
  engine_version = "8.0"
  instance_class = "db.t3.micro"
  db_name = var.db_name
  password = var.db_password
  username = var.db_username
  db_subnet_group_name = aws_db_subnet_group.main-subnet.id
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

}
 
