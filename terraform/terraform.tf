provider "aws" { region = "us-east-1" }

output "bastion.public_ip" {
	value = "${aws_instance.bastion.public_ip}"
}

resource "aws_subnet" "mongeeses_subnet_1" {
	vpc_id = "${aws_vpc.mongeeses_vpc.id}"
	availability_zone = "us-east-1a"
	cidr_block = "10.0.1.0/26"

	tags {
		Name = "mongeeses_subnet_1"
	}
}

resource "aws_subnet" "mongeeses_subnet_2" {
	vpc_id = "${aws_vpc.mongeeses_vpc.id}"
	availability_zone = "us-east-1b"
	cidr_block = "10.0.1.64/26"
}

resource "aws_instance" "bastion" {
	ami = "ami-c481fad3"
	subnet_id = "${aws_subnet.mongeeses_subnet_1.id}"
	associate_public_ip_address = true
	key_name = "mongeeses"
	instance_type = "t2.micro"
	vpc_security_group_ids = ["${aws_security_group.bastion_sg.id}"]
}

resource "aws_vpc" "mongeeses_vpc" {
	cidr_block = "10.0.1.0/24"
}

resource "aws_internet_gateway" "mongeeses_gw" {
	vpc_id = "${aws_vpc.mongeeses_vpc.id}"
}

resource "aws_route_table" "mongeeses_route_table" {
	vpc_id = "${aws_vpc.mongeeses_vpc.id}"
	route {
		cidr_block = "0.0.0.0/0"
		gateway_id = "${aws_internet_gateway.mongeeses_gw.id}"
	}
}

# more specific configuration ??
resource "aws_route_table_association" "mongeeses_route_subnet_1" {
	subnet_id = "${aws_subnet.mongeeses_subnet_1.id}"
	route_table_id = "${aws_route_table.mongeeses_route_table.id}"
}

resource "aws_route_table_association" "mongeeses_route_subnet_2" {
	subnet_id = "${aws_subnet.mongeeses_subnet_2.id}"
	route_table_id = "${aws_route_table.mongeeses_route_table.id}"
}

#Security Groups
resource "aws_security_group" "bastion_sg" {
	vpc_id = "${aws_vpc.mongeeses_vpc.id}"

	ingress {
		from_port = 8
		to_port = 0
		protocol = "icmp"
		cidr_blocks = ["0.0.0.0/0"]
	}
	
	ingress {
		from_port = 22
		to_port = 22
		protocol = "tcp"
		cidr_blocks = ["${aws_vpc.mongeeses_vpc.cidr_block}"]
	}

	egress {
		from_port = 0
		to_port = 0
		protocol = "-1"
		cidr_blocks = ["0.0.0.0/0"]
	}
}

resource "aws_security_group" "alb_sg" {
        vpc_id = "${aws_vpc.mongeeses_vpc.id}"

        ingress {
                from_port = 80
                to_port = 80
                protocol = "tcp"
                cidr_blocks = ["0.0.0.0/0"]
        }

        egress {
                from_port = 80
                to_port = 80
                protocol = "tcp"
                cidr_blocks = ["10.0.1.0/24"]
        }
}

resource "aws_security_group" "mongeeses_web_sg" {
	vpc_id = "${aws_vpc.mongeeses_vpc.id}"

	ingress {
		from_port = 80
		to_port = 80
		protocol = "tcp"
		security_groups = ["${aws_security_group.alb_sg.id}"]
	}

	ingress {
		from_port = 22
		to_port = 22
		protocol = "tcp"
		security_groups = ["${aws_security_group.alb_sg.id}"]
	}

	egress {
		from_port = 0
		to_port = 0
		protocol = "-1"
		cidr_blocks = ["0.0.0.0/0"]
	}
}

resource "aws_alb" "mongeeses_alb" {
	name = "mong2-alb"
	subnets = ["${aws_subnet.mongeeses_subnet_1.id}", "${aws_subnet.mongeeses_subnet_2.id}"] 
	security_groups = ["${aws_security_group.alb_sg.id}"]
}

resource "aws_alb_target_group" "mongeeses_alb" {
	name = "mong-alb-target"
	vpc_id = "${aws_vpc.mongeeses_vpc.id}"
	port = 80
	protocol = "HTTP"
	health_check {
		matcher = "200,301"
		interval = "10"
	}
}

resource "aws_alb_listener" "mongeeses_alb_http" {
	load_balancer_arn = "${aws_alb.mongeeses_alb.arn}"
	port = 80
	protocol = "HTTP"
	default_action {
		target_group_arn = "${aws_alb_target_group.mongeeses_alb.arn}"
		type = "forward"
	}
}

output "alb.dns" {
	value = "${aws_alb.mongeeses_alb.dns_name}"
}
