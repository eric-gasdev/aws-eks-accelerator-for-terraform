resource "kubernetes_namespace_v1" "crossplane" {
  metadata {
    name = local.namespace

    labels = {
      "app.kubernetes.io/managed-by" = "terraform-ssp-amazon-eks"
    }
  }
}

module "helm_addon" {
  source            = "../helm-addon"
  manage_via_gitops = var.manage_via_gitops
  helm_config       = local.helm_config
  irsa_config       = null
  addon_context     = var.addon_context

  depends_on = [kubernetes_namespace_v1.crossplane]
}

#--------------------------------------
# AWS Provider
#--------------------------------------
resource "kubectl_manifest" "aws_controller_config" {
  count = var.aws_provider.enable == true ? 1 : 0
  yaml_body = templatefile("${path.module}/aws-provider/aws-controller-config.yaml", {
    iam-role-arn = "arn:${var.addon_context.aws_partition_id}:iam::${var.addon_context.aws_caller_identity_account_id}:role/${var.addon_context.eks_cluster_id}-${local.aws_provider_sa}-irsa"
  })
  depends_on = [module.helm_addon]
}

resource "kubectl_manifest" "aws_provider" {
  count = var.aws_provider.enable == true ? 1 : 0
  yaml_body = templatefile("${path.module}/aws-provider/aws-provider.yaml", {
    provider-aws-version = var.aws_provider.provider_aws_version
    aws-provider-name    = local.aws_provider_sa
  })
  wait       = true
  depends_on = [kubectl_manifest.aws_controller_config]
}

module "aws_provider_irsa" {
  count                             = var.aws_provider.enable == true ? 1 : 0
  source                            = "../../../modules/irsa"
  create_kubernetes_namespace       = false
  create_kubernetes_service_account = false
  kubernetes_namespace              = local.namespace
  kubernetes_service_account        = "${local.aws_provider_sa}-*"
  irsa_iam_policies                 = concat([aws_iam_policy.aws_provider[0].arn], var.aws_provider.additional_irsa_policies)
  addon_context                     = var.addon_context

  depends_on = [kubectl_manifest.aws_provider]
}

resource "aws_iam_policy" "aws_provider" {
  count       = var.aws_provider.enable == true ? 1 : 0
  description = "Crossplane AWS Provider IAM policy"
  name        = "${var.addon_context.eks_cluster_id}-${local.aws_provider_sa}-irsa"
  policy      = data.aws_iam_policy_document.s3_policy.json
  tags        = var.addon_context.tags
}

resource "kubectl_manifest" "aws_provider_config" {
  count     = var.aws_provider.enable == true ? 1 : 0
  yaml_body = templatefile("${path.module}/aws-provider/aws-provider-config.yaml", {})

  depends_on = [kubectl_manifest.aws_provider]
}

#--------------------------------------
# Terrajet AWS Provider
#--------------------------------------
resource "kubectl_manifest" "jet_aws_controller_config" {
  count = var.jet_aws_provider.enable == true ? 1 : 0
  yaml_body = templatefile("${path.module}/aws-provider/jet-aws-controller-config.yaml", {
    iam-role-arn = "arn:${local.aws_current_partition}:iam::${local.aws_current_account_id}:role/${var.addon_context.eks_cluster_id}-${local.jet_aws_provider_sa}-irsa"
  })

  depends_on = [module.helm_addon]
}

resource "kubectl_manifest" "jet_aws_provider" {
  count = var.jet_aws_provider.enable == true ? 1 : 0
  yaml_body = templatefile("${path.module}/aws-provider/jet-aws-provider.yaml", {
    provider-aws-version = var.jet_aws_provider.provider_aws_version
    aws-provider-name    = local.jet_aws_provider_sa
  })
  wait = true

  depends_on = [kubectl_manifest.jet_aws_controller_config]
}

module "jet_aws_provider_irsa" {
  count = var.jet_aws_provider.enable == true ? 1 : 0

  source                            = "../../../modules/irsa"
  create_kubernetes_namespace       = false
  create_kubernetes_service_account = false
  kubernetes_namespace              = local.namespace
  kubernetes_service_account        = "${local.jet_aws_provider_sa}-*"
  irsa_iam_policies                 = concat([aws_iam_policy.jet_aws_provider[0].arn], var.jet_aws_provider.additional_irsa_policies)
  addon_context                     = var.addon_context

  depends_on = [kubectl_manifest.jet_aws_provider]
}

resource "aws_iam_policy" "jet_aws_provider" {
  count       = var.jet_aws_provider.enable == true ? 1 : 0
  description = "Crossplane Jet AWS Provider IAM policy"
  name        = "${var.addon_context.eks_cluster_id}-${local.jet_aws_provider_sa}-irsa"
  policy      = data.aws_iam_policy_document.s3_policy.json
  tags        = var.addon_context.tags
}

resource "kubectl_manifest" "jet_aws_provider_config" {
  count     = var.jet_aws_provider.enable == true ? 1 : 0
  yaml_body = templatefile("${path.module}/aws-provider/jet-aws-provider-config.yaml", {})

  depends_on = [kubectl_manifest.jet_aws_provider]
}
