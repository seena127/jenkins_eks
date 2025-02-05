provider "aws" {
    region= var.aws_region
  
}
resource "aws_vpc" "vpc" {
    cidr_block = var.vpc_cidr_block
    enable_dns_hostnames = "true"
  
}
resource "aws_subnet" "sub1" {
    cidr_block = var.sub1_cidr
    map_public_ip_on_launch = true
    vpc_id = aws_vpc.vpc.id
  
}
resource "aws_internet_gateway" "iga" {
    vpc_id = aws_vpc.vpc.id
  
}
resource "aws_route_table" "rtb1" {
    vpc_id = aws_vpc.vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.iga.id

    }
}
resource "aws_route_table_association" "rtba1" {
    subnet_id = aws_subnet.sub1.id
    route_table_id = aws_route_table.rtb1.id
  
}
resource "aws_security_group" "nsg" {
    name = "Jenkins_NSG"
    vpc_id = aws_vpc.vpc.id
    egress{
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 9000
        to_port = 9000
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
  
}
resource "aws_instance" "jenkins" {
    
    ami = "ami-04b4f1a9cf54c11d0"
    key_name = "devops_practice"
    instance_type = var.instance_type
    subnet_id = aws_subnet.sub1.id
    security_groups = [aws_security_group.nsg.id]
    tags = {
      Name = "Jenkins-Instance"
    }
    provisioner "remote-exec" {
        inline = [
      "sudo apt-get update -y",
      "sudo apt install -y openjdk-17-jdk",
      "sudo update-alternatives --config java",
      "sudo apt-get install docker.io -y",
      "sudo systemctl enable docker",
      "sudo systemctl start docker",
      "sudo usermod -aG docker ubuntu",
      "sudo wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key",
      "echo 'deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/' | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null",
      "sudo apt-get update",
      "sudo apt-get install -y jenkins",
      "sudo systemctl enable jenkins",
      "sudo systemctl start jenkins",
      "sudo usermod -aG docker jenkins",
      "sudo systemctl restart jenkins",
      "sudo apt-get update -y"
    ]

         connection {
           type = "ssh"
           user = "ubuntu"
           private_key = file("C:/Users/prasad/Desktop/kubernetes/projects/project-1/devops_practice.pem")
           host = self.public_ip
         }
      
    }

  
}
output "ec2_public_ip" {
  
value = aws_instance.jenkins.public_ip
}
