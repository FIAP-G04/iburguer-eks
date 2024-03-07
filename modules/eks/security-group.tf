/*resource "aws_security_group" "sg" {
    vpc_id = var.vpc_id
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
    }
    ingress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        self = "true"
    }
    tags = {
        Name = "${var.prefix}-sg"
    }
}*/