terraform {
  cloud {
    organization = "DSI-Dev-Mckinsey"

    workspaces {
      name = "DSI-DEV"
    }
  }
}


resource "aws_vpc" "dsi_dev_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "DSI-DEV-Project"
  }
}
resource "aws_internet_gateway" "dsi_dev_igw" {
  vpc_id = aws_vpc.dsi_dev_vpc.id
  tags = {
    Name = "dsi-dev igw"
  }

}
resource "aws_route_table" "dsi_dev_rt" {
  vpc_id = aws_vpc.dsi_dev_vpc.id
  route {
    cidr_block = "0.0.0.0/16"
    gateway_id = aws_internet_gateway.dsi_dev_igw.id
  }
  tags = {
    Name = "dsi-dev rt"
  }
}
resource "aws_subnet" "dsi_dev_subnet-01" {
  vpc_id            = aws_vpc.dsi_dev_vpc.id
  cidr_block        = var.dsi_dev_subnet
  availability_zone = "us-east-1"
  tags = {
    Name = "tf prod public subnet"
  }
}

resource "aws_route_table_association" "tf_rtsnet1" {
  subnet_id      = aws_subnet.dsi_dev_subnet-01.id
  route_table_id = aws_route_table.dsi_dev_rt.id
}

resource "aws_security_group" "allow_web" {
  vpc_id = aws_vpc.dsi_dev_vpc.id
  name   = "allow_web_traffic"



  ingress {
    from_port   = 443
    to_port     = 443
    description = "https"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_network_interface" "webserver_nic" {
  subnet_id       = aws_subnet.dsi_dev_subnet-01.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.allow_web.id]

}

resource "aws_eip" "public_ip_web" {
  network_interface         = aws_network_interface.webserver_nic.id
  associate_with_private_ip = "10.0.1.50"
  depends_on                = [aws_internet_gateway.dsi_dev_igw]
}

resource "aws_instance" "tf_prod_web" {
  ami               = "ami-07fd1de5f10a3eb14"
  instance_type     = var.instance_type
  availability_zone = "us-east-1"
  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.webserver_nic.id
  }
  user_data = <<-EOF
              sudo apt update -y
              sudo apt install apache2 -y
              sudo systemctl start apache2
              EOF


  tags = {
    Name = "TerraformEc2 - ${local.project_name}"
  }
}

# module "vpc" {
#   source = "terraform-aws-modules/vpc/aws"

#   name = "my-vpc"
#   cidr = "100.0.0.0/16"

#   azs             = ["us-east-1"]
#   private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
#   public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

#   enable_nat_gateway = false
#   enable_vpn_gateway = false

#   tags = {
#     Terraform = "true"
#     Environment = "dev"
#   }
# }