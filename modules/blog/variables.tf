variable "instance_type" {
  description = "Type of EC2 instance to provision"
  default     = "t3.nano"
}

variable "ami_filter" {
  description      = "Instance AMI and AMI owner"

  type             = object({
    ami_name       = string
    ami_owner       = string
  })
  default         = {
    ami_name       = "aws-elasticbeanstalk-amzn-2.0.20240223*"
    ami_owner       = "964913206263"
  }
}

variable "subnet_prefix" {
  description              = "Subnet prefix"
  type                     = string
  default                  = "10.0"
}
