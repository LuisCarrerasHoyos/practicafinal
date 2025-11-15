variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "sa-east-1"
}

#variable "public_key" {
#  description = "SSH public key to access the instances"
#  type        = string
#}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "List of CIDRs for the two public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "instance_type_web" {
  description = "Instance type for web server"
  type        = string
  default     = "t3.micro"
}

variable "instance_type_db" {
  description = "Instance type for database server"
  type        = string
  default     = "t3.micro"
}
