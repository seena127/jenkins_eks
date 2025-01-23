variable "vpc_cidr_block" {
    type = string
    default = "10.0.0.0/16"
  
}
variable "sub1_cidr" {
    type = string
    default = "10.0.0.0/24"
  
}
variable "instance_type" {
    type = string
    default = "t2.micro"
}