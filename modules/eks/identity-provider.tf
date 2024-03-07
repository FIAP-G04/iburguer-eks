/*data "tls_certificate" "eks-cert" {
  url = aws_eks_cluster.cluster.identity.0.oidc.0.issuer
}

resource "aws_iam_openid_connect_provider" "oidc-eks" {
  client_id_list = ["sts.amazonaws.com"]
  thumbprint_list = [ data.tls_certificate.eks-cert.certificates[0].sha1_fingerprint ]
  url = aws_eks_cluster.cluster.identity.0.oidc.0.issuer
}

data "aws_iam_policy_document" "pd-eks" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect = "Allow"
    condition {
      test = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.oidc-eks.url, "https://", "")}:sub"
      values = [ "system:serviceaccount:kube-system:aws-node" ]
    }
    principals {
      identifiers = [ aws_iam_openid_connect_provider.oidc-eks.arn ]
      type = "Federated"
    }
  }
}

resource "aws_iam_role" "aws_node" {
  assume_role_policy = data.aws_iam_policy_document.pd-eks.json
  name = "${var.prefix}-aws-node"
}

resource "aws_eks_identity_provider_config" "ipconf-cluster" {
  cluster_name = aws_eks_cluster.cluster.name
  oidc {
    client_id = "${substr(aws_eks_cluster.cluster.identity.0.oidc.0.issuer, -32, -1)}"
    identity_provider_config_name = "sdemonew"
    issuer_url = "https://${aws_iam_openid_connect_provider.oidc-eks.url}"
  }
}*/