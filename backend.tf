terraform {
   backend "s3" {
      bucket_name    = "backend10775"
      key            = "ec2/terraform.tfstate"
      dynamodb_table = "backend2"
      encrypt        = true
      region         = var.aws_region
  }
}
      
