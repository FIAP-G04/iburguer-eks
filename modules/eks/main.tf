/*
resource "aws_eks_cluster" "cluster" {
    name = "${var.prefix}-${var.cluster_name}"
    role_arn = aws_iam_role.cluster.arn
    enabled_cluster_log_types = ["api","audit"]
    vpc_config {
        subnet_ids = var.subnet_ids
        security_group_ids = [aws_security_group.sg.id]
    }
    depends_on = [ 
        aws_cloudwatch_log_group.log,
        aws_iam_role_policy_attachment.cluster-AmazonEKSClusterPolicy,
        aws_iam_role_policy_attachment.cluster-AmazonEKSVPCResourceController
    ]
}*/

resource "aws_security_group" "eks" {
    name        = "${var.prefix}-${var.cluster_name}"
    description = "Allow traffic"
    vpc_id      = var.vpc_id

    ingress {
      description      = "World"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }

    egress {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }

    tags = {
      Name = "${var.prefix}-sg"
    }
  }

  module "eks" {
    source = "terraform-aws-modules/eks/aws"
    version = "18.19.0"

    cluster_name                    = "${var.prefix}-${var.cluster_name}"
    cluster_version                 = "1.29"
    cluster_endpoint_private_access = true
    cluster_endpoint_public_access  = true
    cluster_additional_security_group_ids = [aws_security_group.eks.id]

    vpc_id     = var.vpc_id
    subnet_ids = var.subnet_ids

    eks_managed_node_group_defaults = {
      ami_type               = "AL2_x86_64"
      disk_size              = 50
      instance_types         = ["t3.micro", "t3.micro"]
      vpc_security_group_ids = [aws_security_group.eks.id]
    }

    eks_managed_node_groups = {
      iburguer = {
        min_size     = 1
        max_size     = 10
        desired_size = 3

        instance_types = ["t3.micro"]
        capacity_type  = "SPOT"
        taints = {
        }
      }
    }
  }
  