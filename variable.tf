variable "aws_region" {
  type = string
  default = "ap-southeast-2"
}

variable "instance_type" {
  type = string
  default = "t3.micro"
}
variable "key_name" {
  type = string
  default = "docker_c1"
  
}
variable "ami_id" {
  type = string
  default = "ami-0b8d527345fdace59"
  
}
variable "vpc_cidr" {
  type = string
  default = "10.0.0.0/16"
}
variable "pub_cidr" {
  type = string
  default = "10.0.1.0/24"
}

variable "db_username" {
  type = string
  default = "shajahan"
}

variable "db_password" {
  type = string
  default = "shaju@123"
}

variable "db_name" {
  type = string
  default = "testdb"
}

variable "availability_zone" {
  type = string 
  default = "ap-southeast-21"
}
