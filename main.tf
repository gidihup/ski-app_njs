##configure the provider
provider "aws" {
	access_key = "${var.access_key}"
	secret_key = "${var.secret_key}"
	region = "${var.region}"
}

#resources
resource "aws_vpc" "ceros_vpc" {
  cidr_block = "${var.cidr_vpc}"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags {
    "Environment" = "${var.environment_tag}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.ceros_vpc.id}"
  tags {
    "Environment" = "${var.environment_tag}"
  }
}

resource "aws_subnet" "subnet_public" {
  vpc_id = "${aws_vpc.ceros_vpc.id}"
  cidr_block = "${var.cidr_subnet}"
  map_public_ip_on_launch = "true"
  availability_zone = "${var.availability_zone}"
  tags {
    "Environment" = "${var.environment_tag}"
  }
}

resource "aws_route_table" "ceros_rtb_public" {
  vpc_id = "${aws_vpc.ceros_vpc.id}"

  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = "${aws_internet_gateway.igw.id}"
  }

  tags {
    "Environment" = "${var.environment_tag}"
  }
}

resource "aws_route_table_association" "rta_subnet_public" {
  subnet_id      = "${aws_subnet.subnet_public.id}"
  route_table_id = "${aws_route_table.ceros_rtb_public.id}"
}

resource "aws_security_group" "sg_access" {
  name = "sg_22"
  vpc_id = "${aws_vpc.ceros_vpc.id}"

  # SSH and http access
  ingress {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

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

  tags {
    "Environment" = "${var.environment_tag}"
  }
}

resource "aws_key_pair" "ec2key" {
  key_name = "publicKey"
  public_key = "${file(var.public_key_path)}"
}

resource "aws_instance" "ceros_app" {
  ami           = "${var.instance_ami}"
  instance_type = "${var.instance_type}"
  subnet_id = "${aws_subnet.subnet_public.id}"
  vpc_security_group_ids = ["${aws_security_group.sg_access.id}"]
  key_name = "${aws_key_pair.ec2key.key_name}"

  tags {
		"Environment" = "${var.environment_tag}"
	}

connection {
    type     = "ssh"
    user     = "ubuntu"
    password = ""
    private_key = "${file("~/.ssh/id_rsa")}"
  }

  provisioner "file" {
    source      = "ceros-ski.zip"
    destination = "~/ceros-ski.zip"
  }
  provisioner "file" {
    source      = "bootstrap.sh"
    destination = "~/bootstrap.sh"
  }

provisioner "remote-exec" {
    inline = [
      "sudo chmod +x ~/bootstrap.sh",
      "sudo ~/bootstrap.sh",
    ]
  }
}