# Existing EKS Cluster IAM Role
data "aws_iam_role" "cluster" {
  name = "${var.project_name}-cluster-role"
}


# Existing EKS Node Group IAM Role
data "aws_iam_role" "nodes" {
  name = "${var.project_name}-node-role"
}

/* # Existing EKS Cluster IAM Role
data "aws_iam_role" "cluster" {
  name = "${var.project_name}-cluster-role"
}


# Existing EKS Node Group IAM Role
data "aws_iam_role" "nodes" {
  name = "${var.project_name}-node-role"
}

# Commented line no:13 to 24 because using existing role - data instead of resource
  #assume_role_policy = jsonencode({
  # Version = "2012-10-17"
  # Statement = [
  #   {
  #     Action = "sts:AssumeRole"
  #     Effect = "Allow"
  #     Principal = {
  #        Service = "eks.amazonaws.com"
  #      }
  #   },
  # ]
  #})
#}

#resource "aws_iam_role_policy_attachment" "cluster_policy" {
#  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
#  role       = aws_iam_role.cluster.name
#}

resource "aws_iam_role_policy_attachment" "nodes_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.nodes.name
}

resource "aws_iam_role_policy_attachment" "nodes_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.nodes.name
}

resource "aws_iam_role_policy_attachment" "nodes_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.nodes.name
} */
