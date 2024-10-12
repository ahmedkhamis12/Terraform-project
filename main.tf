provider "aws"{
    region ="us-east-1"
    
}

variable "avil_zone"{}
variable "vpc_cidr_block" {}
variable "subnet_cidr_block" {}
variable "env" {}
variable "my_ip"{}
variable "instance_type"{}
variable "public_key_location"{}

resource "aws_vpc" "my-vpc" {
    cidr_block = var.vpc_cidr_block
    tags = {
        Name= "${var.env}-vpc"
    }
}




resource "aws_subnet" "my-app-subnet" {
    vpc_id = aws_vpc.my-vpc.id
    cidr_block = var.subnet_cidr_block
    availability_zone = var.avil_zone
    tags = {
        Name= "${var.env}-subnet"
    }

}

# resource "aws_route_table" "my-app-route"{
#     vpc_id = aws_vpc.my-vpc.id
#     route{
#         cidr_block = "0.0.0.0/0"
#         gateway_id = aws_internet_gateway.my-app-internet-gateway.id
#     }
#     tags = {
#         Name= "${var.env}-rtb"
#     }
# }

resource "aws_internet_gateway" "my-app-internet-gateway"{
    vpc_id = aws_vpc.my-vpc.id

}

# resource "aws_route_table_association" "rtb-subnet-association"{
#     subnet_id = aws_subnet.my-app-subnet.id
#     route_table_id = aws_route_table.my-app-route.id
# }

resource "aws_default_route_table" "main-rtb"{
    default_route_table_id = aws_vpc.my-vpc.default_route_table_id
    route{
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.my-app-internet-gateway.id
    }
    tags = {
        Name= "${var.env}-main-rtb"
    }


}

resource "aws_security_group" "myapp-sg"{
    name = "my-app-sg"
    vpc_id = aws_vpc.my-vpc.id

    ingress {
        from_port  = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks= [var.my_ip]
    }

    ingress {
        from_port  = 8080
        to_port = 8080
        protocol = "tcp"
        cidr_blocks= ["0.0.0.0/0"]
    }

    egress {
        from_port  = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks= ["0.0.0.0/0"]
        prefix_list_ids = []
    }

    tags = {
        Name= "${var.env}-my-app-sg"
    }
}

resource "aws_instance" "myapp-server" {
    ami = data.aws_ami.amazon-linux-image.id
    instance_type = var.instance_type
    subnet_id = aws_subnet.my-app-subnet.id
    vpc_security_group_ids = [aws_security_group.myapp-sg.id]
    availability_zone = var.avil_zone
    associate_public_ip_address = true
    key_name = aws_key_pair.ssh-key.key_name
    user_data =<<EOF
                #!/bin/bash
                sudo yum update -y 
                sudo yum install docker -y
                sudo systemctl start docker
                sudo systemctl enable docker
                sudo chmod 666 /var/run/docker.sock
                sudo chown $USER /var/run/docker.sock
                sudo usermod -aG docker ec2-user
                docker run -p 8080:80 nginx
                sleep 30
                EOF
    tags = {
        Name= "${var.env}-server"
    }
}

data "aws_ami" "amazon-linux-image" {
    most_recent = true
    owners = ["amazon"]
    filter {
    name = "name"
    values = ["amzn2-ami-*-x86_64-gp2"]
    }
    filter {
    name = "virtualization-type"
    values = ["hvm"]
    }
}

output "ami_id" {
    value = data.aws_ami.amazon-linux-image

}

resource "aws_key_pair" "ssh-key"{
    key_name = "myapp-key"
    public_key= file(var.public_key_location)

}

output "my-server-ip"{
    value = aws_instance.myapp-server.public_ip
}