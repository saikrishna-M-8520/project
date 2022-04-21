variable "aws_region" {
    default = "us-west-2"
}

variable "ami_id" {
    // Ubuntu Server 18.04 LTS (HVM), SSD Volume Type in us-west-2 
    default = "ami-0d1cd67c26f5fca19"
}

variable "amiw_id" {
    // Windows instance in us-west-2
    default = "ami-080715d89cbdd661e"
}


variable "instance_type" {
  default = "t2.micro"
}

variable "aws_access_key" {
  default = "AKIA4LBNQ4XXWUJSIERB"
}

variable "aws_secret_key" {
  default = "9vjDAZGeSZ7Lj69su//hFbGt9vYM0KocUZcDlTdo"
}

variable "bucket_name" {
  default = "applications-storage"
}

variable "acl_value" {
  default = "private"
}
