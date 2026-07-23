resource "aws_eks_cluster" "vp" {
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  name                      = "vp-sd2-eks-${random_id.s.hex}"
  role_arn                  = "arn:aws:iam::746210888062:role/vp-companion-856b2431"
  version                   = "1.30"

  vpc_config {
    # companion 1d subnet + an existing 1b subnet in the same VPC.
    # (companion 1e subnet-0a0a41f888339dd65 is in us-east-1e, which EKS does
    #  not support for control-plane; swapped for supported-AZ subnet.)
    subnet_ids = ["subnet-0dd7628650cbd31c3", "subnet-0cbeafce2becbdcae"]

    # VIOLATING: EKS.1 — endpoint public access enabled
    endpoint_public_access  = false
    endpoint_private_access = true
  }

  # VIOLATING: EKS.2 — no enabled_cluster_log_types (audit logs disabled)
  # VIOLATING: EKS.8 — no encryption_config (secrets encryption disabled)
}
