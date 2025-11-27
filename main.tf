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
  availability_zone       = var.availability_zone

  tags = {
    Name = "public"
  }
}

resource "aws_subnet" "private" {
   cidr_block = var.private_cidr
   vpc_id = aws_vpc.vpc_rds.id
   availability_zone       = var.availability_zone

   tags = {
     Name = "private"
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

   tags = {
     Name = "rd_tab"
  }
}

resource "aws_route" "rds_r" {
  gateway_id = aws_internet_gateway.igw4.id
  cidr_block = "0.0.0.0/0"
}

resource "aws_security_groug" "ec2_sg1" {
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
  aws_security_group_ids = [aws_security_group_id.ec2-sg1.id]

  
  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              amazon-linux-extras install nginx1 -y
              systemctl enable nginx
              systemctl start nginx
              # Simple signup page
              cat <<EOT > /usr/share/nginx/html/index.html
              <html><body>
              <h1>Signup</h1>
              <form action="/signup.php" method="post">
              Name: <input type="text" name="name"><br>
              Mobile: <input type="text" name="mobile"><br>
              Password: <input type="password" name="password"><br>
              <input type="submit" value="Sign Up">
              </form>
              </body></html>
              EOT
              EOF

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
    security_groups = [aws_security_group.rds_sg.id]
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
 }

#creating rds instance

resource "aws_db_subnet_group" "main-subnet" {
  Name = "main_subnet"
  subnet_ids = [aws_subnet.private.id]

  tags = {
    Name = "main-subnet"
  }
}

resource "aws_db_instance" "mysql" {
  allocated_storage = 20
  engine = "mysql"
  engine_version = "8.0"
  instance_class = "db.t3.micro"
  name = var.db_name
  password = var.db_password
  username = var.db_username
  db_subnet_group_name = aws_db_subnet_group.main-subent.id
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  tags = {
    Name = "mysql"
  }
}
 
