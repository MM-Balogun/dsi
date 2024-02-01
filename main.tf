

/*
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
resource "aws_subnet" "subnet_cidr-01" {
  vpc_id            = aws_vpc.dsi_dev_vpc.id
  cidr_block        = var.subnet_cidr
  availability_zone = "us-east-1"
  tags = {
    Name = "tf prod public subnet"
  }
}

resource "aws_route_table_association" "tf_rtsnet1" {
  subnet_id      = aws_subnet.subnet_cidr-01.id
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
  subnet_id       = aws_subnet.subnet_cidr-01.id
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
*/





resource "aws_vpc" "dsi_dev_vpc" {
  cidr_block = var.vpc_cidr_block
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
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dsi_dev_igw.id
  }
  tags = {
    Name = "dsi-dev rt"
  }
}

resource "aws_subnet" "subnet_cidr" {
  vpc_id            = aws_vpc.dsi_dev_vpc.id
  cidr_block        = var.subnet_cidr
  availability_zone = "${var.aws_region}a"
  tags = {
    Name = "dsi-dev subnet"
  }
}

resource "aws_route_table_association" "dsi_dev_rta" {
  subnet_id      = aws_subnet.subnet_cidr.id
  route_table_id = aws_route_table.dsi_dev_rt.id
}

resource "aws_security_group" "allow_web" {
  vpc_id = aws_vpc.dsi_dev_vpc.id
  name   = "allow_web_traffic"

  ingress {
    from_port   = 443
    to_port     = 443
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

resource "aws_instance" "web_instance" {
  ami               = var.ami_id
  instance_type     = var.instance_type
  subnet_id         = aws_subnet.subnet_cidr.id
  vpc_security_group_ids = [aws_security_group.allow_web.id]

  tags = {
    Name = "Web Instance"
  }
}

# EKS Cluster
module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = var.eks_cluster_name
  cluster_version = "1.21"
  # subnets         = [aws_subnet.subnet_cidr.id]
  vpc_id          = aws_vpc.dsi_dev_vpc.id
  eks_managed_node_group_defaults = {
    disk_size = 50
  }

  eks_managed_node_groups = {
    general = {
      desired_size = 1
      min_size     = 1
      max_size     = 10

      labels = {
        role = "general"
      }

      instance_types = ["t3.small"]
      capacity_type  = "ON_DEMAND"
    }

    spot = {
      desired_size = 1
      min_size     = 1
      max_size     = 10

      labels = {
        role = "spot"
      }

      taints = [{
        key    = "market"
        value  = "spot"
        effect = "NO_SCHEDULE"
      }]

      instance_types = ["t3.micro"]
      capacity_type  = "SPOT"
    }
  }

  tags = {
    Environment = "DEV"
  }
  # node_groups = {
  #   default = {
  #     name             = var.node_group_name
  #     instance_type    = var.node_instance_type
  #     desired_capacity = var.node_desired_capacity
  #     min_capacity     = var.node_min_capacity
  #     max_capacity     = var.node_max_capacity
  #   }
  # }
}
