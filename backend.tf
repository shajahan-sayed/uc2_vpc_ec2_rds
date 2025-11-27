terraform {
   backend "s3" {
      bucket         = "backend10775"
      key            = "ec2/terraform.tfstate"
      dynamodb_table = "backend2"
      encrypt        = true
      region         = "ap-southeast-2"
  }
}
      
