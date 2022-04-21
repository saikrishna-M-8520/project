provider "aws" {
    region                  = var.aws_region
    access_key              = var.aws_access_key
    secret_key              = var.aws_secret_key
}

module "vpc" {
    source = "./modules/vpc-double"
    vpc_name = "db-sample"
    vpc_cidr = "192.168.0.0/16"
    public1_cidr = "192.168.1.0/24"
    public2_cidr = "192.168.4.0/24"
    private1_cidr = "192.168.2.0/24"
    private2_cidr = "192.168.3.0/24"
    private1_az = data.aws_availability_zones.available.names[0]
    private2_az = data.aws_availability_zones.available.names[1]
    public1_az = "us-west-2b"
    public2_az = "us-west-2c"
}

resource "aws_s3_bucket" "demos3" {
    bucket = var.bucket_name 
    acl = var.acl_value   
}

data "aws_availability_zones" "available" {
  state = "available"
}


resource "aws_security_group" "ec2-sg" {
  name        = "security-group"
  description = "allow inbound access to the EC2 instance"
  vpc_id      = module.vpc.vpc_id

  ingress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_role" "role" {
  name = "test-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_group" "group" {
  name = "test-group"
}

resource "aws_iam_policy" "policy" {
  name        = "test-policy"
  description = "A test policy"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "s3:*",
            "Resource": "*",
            "Sid": "AllowRDSDescribe",
            "Effect": "Allow",
            "Action": "rds:Describe*",
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_policy_attachment" "test-attach" {
  name       = "test-attachment"
  groups     = [aws_iam_group.group.name]
  roles      = [aws_iam_role.role.name]
  policy_arn = aws_iam_policy.policy.arn
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name       = "ec2_profile"
  role       = aws_iam_role.role.name
}

resource "aws_instance" "public-ec2" {
    ami           = var.ami_id
    instance_type = var.instance_type
    subnet_id     = module.vpc.subnet_public1_id
    key_name      = "golang"
    iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
    vpc_security_group_ids = [ aws_security_group.ec2-sg.id ]
    associate_public_ip_address = true

    tags = {
        Name = "ec2-main"
    }

    depends_on = [ module.vpc.vpc_id, module.vpc.igw_id ]

    user_data = <<EOF
#!/bin/sh
sudo apt-get update
sudo apt-get install -y mysql-client
EOF
}

resource "aws_instance" "windows" {
  ami           = var.amiw_id
  instance_type = var.instance_type
  associate_public_ip_address = true
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
  key_name = "golang"
  vpc_security_group_ids = [aws_security_group.ec2-sg.id]
  subnet_id     = module.vpc.subnet_public1_id

  tags = {
    Name = "windows-server"

}

}
