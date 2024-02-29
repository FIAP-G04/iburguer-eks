output "vpc_id" {
    value = aws_vpc.new-vpc.id 
}

output "subnet_ids" {
  value = aws_subnet.new-subnets[*].id
}