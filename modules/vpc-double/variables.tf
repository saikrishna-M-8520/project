variable "vpc_cidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "CIDR for VPC"
}

variable "tenancy" {
  type        = string
  default     = "default"
  description = ""
}

variable "enable_dns_support" {
    default = true
}

variable "enable_dns_hostnames" {
    default = true
}

variable "vpc_name" {
  type        = string
  default     = "main"
  description = ""
}

variable "public1_cidr" {}
variable "public2_cidr" {}
variable "private1_cidr" {}
variable "private2_cidr" {}

variable "private1_az" {}
variable "private2_az" {}
variable "public1_az" {
    default = "us-west-1b"
}
variable "public2_az" {
    default = "us-west-1c"
}
