resource "aws_internet_gateway" "new-igw" {
    vpc_id = aws_vpc.vpc.id
    tags = {
        Name = "${var.prefix}-igw"
    }
}