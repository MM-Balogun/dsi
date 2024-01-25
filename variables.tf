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