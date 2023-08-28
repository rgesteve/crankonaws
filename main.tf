terraform {
    required_version = ">=0.12.6"

    # required_providers = {
    #     aws = {
    #         source = "hashicorp/aws"
    #     }
    # }
}

provider "aws" {
  region = "us-east-2"
}

variable "sg_whitelist_cidr_blocks" {
    type = list(string)
    default = ["192.55.79.160/27",
               "198.175.68.32/27", 
               "192.55.54.32/27",
               "192.55.55.32/27",
               "134.191.232.64/27",
               "134.191.233.192/27",
               "192.198.151.32/27",
               "134.191.227.32/27",
               "134.134.139.64/27",
               "134.134.137.64/27",
               "134.191.220.64/27",
               "134.191.221.64/27",
               "192.198.146.160/27",
               "192.198.147.160/27",
               "192.102.204.32/27",
               "192.55.46.32/27",
               "134.191.196.160/27",
               "134.191.197.160/27"]
}

resource "aws_key_pair" "my-identity-pem" {
    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCWL0jMtMdtfnoG8C9szpuz/sgEdzvw1F1f+i9Y+Pf3ajLJEhuyscFDMaNkT6g9KV5w6LPyLqUWGD4p+6MWq2JGV0AE2Jw/YEiscLGN0sCJJcZ8p99lOxzZFtD8B9H32hdoNfdQfvA6Ae0T0WI9nngXfmZBb9r6JiBietdK/nwGEzh1FGA76pCN6FCFYAK6VDpKfdPObLKWkqJW/SBP1bKBmhpcTUPdWu6pNnrgpBL3A6MXpp4Fh+nNrs4+jMRzy+btVA5ZAnCjbjnD7xj8Z8sQiZSO0rVEU8FLwVIJMDQNS2z0CYjZlVCH9MMIOC9NISRr19Uj7S5XWxZ6+8TtZiyGFfxXmLk/8SSvMWVZ+c8d9xlSk3qIxn9vPddZH8CxJQaGK8hNZzNV+MUfk77k6F+NOouzcbtyjdBHuGvke7iaNj08okO7Twdib4zhNIPFkuBgBOUC10XLjPV1ug6DKiTRdA3LO5x5edXqAzh0WITQyvRWP4Q8DfDfVRNLFSi8leiT42ZjZY4fNyAnDt8+ybd1Fst/+DKGVIPYE/4Nh8vzrlwIFYhjA7tWDd94JBo3bwgkZvRCPZ9Zm2EWHMf9d7fvx4N42qzr0SIzqNnuOmVxJ4+3A8ZEJ93R8tY44BV7zDUTIW+9inIbyYBwkgfbCgdcxXGPugUbQGzJQAtz3lHQgQ== amr\rgesteve@rgesteve-dev"
    key_name = "MyIdentity.pem"
}

resource "aws_default_security_group" "allow_ssh_from_intel" {
    #name = "single_node_secgroup"
    #description = "Simple Security Group for a single EC2 instance"
    vpc_id      = aws_vpc.gabe_vpc.id

    ingress {
        description = "SSH"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = var.sg_whitelist_cidr_blocks
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port        = 0
        to_port          = 0
        protocol         = "-1"
        cidr_blocks      = [ "10.0.0.0/16" ]
    }
}

resource "aws_vpc" "gabe_vpc" {
    cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "gabe_subnet" {
    vpc_id = aws_vpc.gabe_vpc.id
    cidr_block = cidrsubnet("10.0.0.0/16", 8, 1)
    map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "gabe_igw" {
    vpc_id = aws_vpc.gabe_vpc.id
}

resource "aws_default_route_table" "gabe_route_table" {
    default_route_table_id = aws_vpc.gabe_vpc.default_route_table_id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.gabe_igw.id
    }
}

# data "template_file" "user_data" {
#     template = file("cloud-init.yml")
# }

# data "cloudinit_config" "testclinit" {
#     gzip = false
#     base64_encode = false
#     part {
#         filename = "/home/ubuntu/set-up-crank.sh"
#         content_type = "text/x-shellscript"
#         content = file("set-up-crank.sh")
#     }
# }

resource "aws_instance" "instance_1" {
    instance_type = "t2.nano"
    #instance_type = "m7i.4xlarge"
    ami = "ami-05d251e0fc338590c"
    subnet_id = aws_subnet.gabe_subnet.id
    associate_public_ip_address = true
    key_name = aws_key_pair.my-identity-pem.key_name
    #security_groups = [aws_security_group.allow_ssh_from_intel.name]
    vpc_security_group_ids = [aws_default_security_group.allow_ssh_from_intel.id]
    #user_data = data.template_file.user_data.rendered
    #user_data = file("cloud-init.yml")
    #user_data = templatefile("cloud-init.yml", { app_ip = aws_instance.app_fake.private_ip })
    # user_data = templatefile("cloud-init.yml", { app_ip = aws_instance.app.private_ip, 
    #                                              db_ip = aws_instance.db.private_ip, 
    #                                              load_ip = aws_instance.loadgen.private_ip, 
    #                                              ssh_key = aws_key_pair.my-identity-pem.key_name,
    #                                              machine = aws_instance.app.instance_type })
    #user_data = data.cloudinit_config.testclinit.rendered

    # Not sure how to pass the Intel proxy spec (scp -o "ProxyCommand=nc -x proxy-us.intel.com:1080 %h %p" -i <private_key> <source> <destination>) 
    # connection {
    #     type = "ssh"
    #     host = self.public_ip
    #     user = "ubuntu"
    #     private_key = file(aws_key_pair.my-identity-pem.key_name)
    # }

    # provisioner "file" {
    #     source = "MyIdentity.pem"
    #     destination = "/home/ubuntu/MyIdentity.pem"

    #     # Apparently terraform allows you to place the connection block nested in the instance or on the provisioner.
    #     # I have it in the instance because I might want to copy more than one file. 
    #     # connection {
    #     #     type = "ssh"
    #     #     host = self.public_ip
    #     #     user = "ubuntu"
    #     #     private_key = file(aws_key_pair.my-identity-pem.key_name)
    #     # }
    # }

    # provisioner "local-exec" {
    #     command = "scp -i ${aws_key_pair.my-identity-pem.key_name} -o StrictHostKeyChecking=no ${aws_key_pair.my-identity-pem.key_name} ubuntu@${self.public_ip}:/home/ubuntu"
    # }

    tags = {
        Name = "rgesteve-crank-controller"
    }
}

resource "aws_instance" "instance_2" {
    instance_type = "t2.nano"
    #instance_type = "m7i.4xlarge"
    ami = "ami-05d251e0fc338590c"
    subnet_id = aws_subnet.gabe_subnet.id
    associate_public_ip_address = true
    key_name = aws_key_pair.my-identity-pem.key_name
    #security_groups = [aws_security_group.allow_ssh_from_intel.name]
    vpc_security_group_ids = [aws_default_security_group.allow_ssh_from_intel.id]
    tags = {
        Name = "rgesteve-crank-controller"
    }
}

# # resource "aws_instance" "app_fake" {
# #     instance_type = "t2.nano"
# #     ami = "ami-05d251e0fc338590c"
# #     subnet_id = aws_subnet.gabe_subnet.id
# #     key_name = aws_key_pair.my-identity-pem.key_name
# #     vpc_security_group_ids = [aws_default_security_group.allow_ssh_from_intel.id]
    
# #     tags = {
# #         Name = "rgesteve-crank-appfake"
# #     }
# # }

# resource "aws_instance" "app" {
#     # SPR
#     #instance_type = "m7i.xlarge"
#     #ami = "ami-05d251e0fc338590c"
#     # Graviton3 (ARM)
#     instance_type = "m7g.xlarge"
#     ami = "ami-0b5801d081fa3a76c"
#     subnet_id = aws_subnet.gabe_subnet.id
#     key_name = aws_key_pair.my-identity-pem.key_name
#     #security_groups = [aws_security_group.allow_ssh_from_intel.name]
#     vpc_security_group_ids = [aws_default_security_group.allow_ssh_from_intel.id]
#     #private_ip = "${cidrhost(aws_vpc.gabe_vpc.cidr_block, 20 + count.index)}"

#     user_data = file("cloud-init-worker.yml")
    
#     tags = {
#         Name = "rgesteve-crank-app"
#     }
# }

# # resource "aws_instance" "worker" {
# #     count = 2
# #     # instance_type = "t2.nano"
# #     instance_type = "m7i.xlarge"
# #     ami = "ami-05d251e0fc338590c"
# #     subnet_id = aws_subnet.gabe_subnet.id
# #     key_name = aws_key_pair.my-identity-pem.key_name
# #     #security_groups = [aws_security_group.allow_ssh_from_intel.name]
# #     vpc_security_group_ids = [aws_default_security_group.allow_ssh_from_intel.id]
# #     #private_ip = "${cidrhost(aws_vpc.gabe_vpc.cidr_block, 20 + count.index)}"
    
# #     tags = {
# #         Name = "rgesteve-crank-worker"
# #     }
# # }

# resource "aws_instance" "loadgen" {
#     instance_type = "m7i.4xlarge"
#     ami = "ami-05d251e0fc338590c"
#     subnet_id = aws_subnet.gabe_subnet.id
#     key_name = aws_key_pair.my-identity-pem.key_name
#     #security_groups = [aws_security_group.allow_ssh_from_intel.name]
#     vpc_security_group_ids = [aws_default_security_group.allow_ssh_from_intel.id]
#     #private_ip = "${cidrhost(aws_vpc.gabe_vpc.cidr_block, 20 + count.index)}"

#     user_data = file("cloud-init-worker.yml")
    
#     tags = {
#         Name = "rgesteve-crank-loadgen"
#     }
# }

# resource "aws_instance" "db" {
#     instance_type = "m7i.xlarge"
#     ami = "ami-05d251e0fc338590c"
#     subnet_id = aws_subnet.gabe_subnet.id
#     key_name = aws_key_pair.my-identity-pem.key_name
#     #security_groups = [aws_security_group.allow_ssh_from_intel.name]
#     vpc_security_group_ids = [aws_default_security_group.allow_ssh_from_intel.id]
#     #private_ip = "${cidrhost(aws_vpc.gabe_vpc.cidr_block, 20 + count.index)}"
    
#     user_data = file("cloud-init-worker.yml")

#     tags = {
#         Name = "rgesteve-crank-db"
#     }
# }

output "login" {
    value = "ssh -o \"ProxyCommand=nc -x proxy-us.intel.com:1080 %h %p\" -i ./${aws_key_pair.my-identity-pem.key_name} ubuntu@${aws_instance.instance_1.public_ip}"
}

output "controller_ip" {
    value = "${aws_instance.instance_1.public_ip}"
}

output "sndbox_ip" {
    value = "${aws_instance.instance_2.public_ip}"
}

# output "app_ips" {
#     value = "The application public IP is: ${aws_instance.app.public_ip}, and its private ip is: ${aws_instance.app.private_ip}."
# }

# output "worker_pubips" {
#     value = "The workers' public IP are 0: ${aws_instance.worker[0].public_ip}, 1: ${aws_instance.worker[1].public_ip}."
# }

# output "worker_privips" {
#     value = "The workers' public IP are 0: ${aws_instance.worker[0].private_ip}, 1: ${aws_instance.worker[1].private_ip}."
# }

# output "private_ips" {
#     value = "The worker private IPs are: app: ${aws_instance.app.private_ip}, loadgen: ${aws_instance.loadgen.private_ip}, and db: ${aws_instance.db.private_ip}."
# }

resource "local_file" "generated_inventory" {
  content = templatefile("inventory_tpl.yaml", {controller_ip = aws_instance.instance_1.public_ip, 
  	    				        sndbox_ip = aws_instance.instance_2.public_ip})
  filename = "generated_inventory.yaml"
}
