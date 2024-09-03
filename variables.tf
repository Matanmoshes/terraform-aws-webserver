variable "ami_id" {
    description = "The AMI ID to use for the EC2 instance"
    type        = string
}

variable "cidr_block" {
    description = "The CIDR block for the VPC"
    type        = string
    #default     = "10.0.0.0/16"
}

variable "subnet_cidrs" {
    description = "value"
    type = list(string)
    default = [ "10.0.3.0/24", "10.0.5.0/24"]
}

variable "key_name" {
    description = "The name of the SSH key pair to use"
    type        = string
}

