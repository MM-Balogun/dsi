/*
locals {
  project_name = "DSI-DEV"
}
variable "dsi_dev_subnet" {
  description = "cidr block for subnet"
  # type = String

}
variable "inwardports" {
  description = "ports allowed for for subnet"
  # type = String

}
variable "instance_type" {
  type = string
}
*/


variable "aws_region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
  description = "CIDR block for the subnet"
  default     = "10.0.0.0/16"
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t2.micro"
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  default     = "ami-07fd1de5f10a3eb14"
}

variable "eks_cluster_name" {
  description = "Name of the EKS cluster"
  default     = "dsi-dev-cluster"
}

variable "node_group_name" {
  description = "Name of the EKS node group"
  default     = "dsi-dev-node-group"
}

variable "node_instance_type" {
  description = "Instance type for the EKS nodes"
  default     = "t2.medium"
}

variable "node_desired_capacity" {
  description = "Desired number of nodes in the EKS node group"
  default     = 3
}

variable "node_min_capacity" {
  description = "Minimum number of nodes in the EKS node group"
  default     = 1
}

variable "node_max_capacity" {
  description = "Maximum number of nodes in the EKS node group"
  default     = 4
}
