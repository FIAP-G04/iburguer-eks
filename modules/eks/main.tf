resource "aws_security_group" "sg" {
    vpc_id = var.vpc_id
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        prefix_list_ids = []
    }
    tags = {
        Name = "${var.prefix}-sg"
    }
}

data "aws_iam_policy_document" "policy-document-cluster" {
    statement {
      effect = "Allow"
      actions = ["sts:AssumeRole"]
      principals {
        type = "Service"
        identifiers = ["eks.amazonaws.com"]
      }
    }
}

resource "aws_iam_role" "cluster" {
    name = "${var.prefix}-${var.cluster_name}-role"
    assume_role_policy = data.aws_iam_policy_document.policy-document-cluster.json
}

resource "aws_iam_role_policy_attachment" "cluster-AmazonEKSVPCResourceController" {
    role = aws_iam_role.cluster.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
}

resource "aws_iam_role_policy_attachment" "cluster-AmazonEKSClusterPolicy" {
    role = aws_iam_role.cluster.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_cloudwatch_log_group" "log" {
    name = "/aws/eks/${var.prefix}-${var.cluster_name}/cluster"
    retention_in_days = var.retention_days
}

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
}


data "aws_iam_policy_document" "policy-document-node" {
    statement {
      effect = "Allow"
      actions = ["sts:AssumeRole"]
      principals {
        type = "Service"
        identifiers = ["ec2.amazonaws.com"]
      }
    }
}

resource "aws_iam_role" "node" {
    name = "${var.prefix}-${var.cluster_name}-role-node"
    assume_role_policy = data.aws_iam_policy_document.policy-document-node.json
}

resource "aws_iam_role_policy_attachment" "node-AmazonEKSWorkerNodePolicy" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
    role = aws_iam_role.node.name
}

resource "aws_iam_role_policy_attachment" "node-AmazonEKS_CNI_Policy" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
    role = aws_iam_role.node.name
}

resource "aws_iam_role_policy_attachment" "node-AmazonEC2ContainerRegistryReadOnly" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
    role = aws_iam_role.node.name
}

resource "aws_eks_node_group" "node-1" {
  cluster_name = aws_eks_cluster.cluster.name
  node_group_name = "node-1"
  node_role_arn = aws_iam_role.node.arn
  subnet_ids = var.subnet_ids
  scaling_config {
    desired_size = var.desired_size
    max_size = var.max_size
    min_size = var.min_size
  }
  instance_types = [ "t3.micro" ]
  depends_on = [ 
    aws_iam_role_policy_attachment.node-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.node-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.node-AmazonEC2ContainerRegistryReadOnly
   ]
}