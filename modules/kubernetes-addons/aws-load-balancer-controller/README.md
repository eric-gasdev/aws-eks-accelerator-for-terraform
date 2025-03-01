# LB Ingress Controller Deployment Guide

# Introduction

AWS Load Balancer Controller is a controller to help manage Elastic Load Balancers for a Kubernetes cluster.

* It satisfies Kubernetes Ingress resources by provisioning Application Load Balancers.
* It satisfies Kubernetes Service resources by provisioning Network Load Balancers.

# Helm Chart

### Instructions to use Helm Charts

Add Helm repo for LB Ingress Controller

    helm repo add aws-load-balancer-controller https://aws.github.io/eks-charts

    https://github.com/aws/eks-charts/blob/master/stable/aws-load-balancer-controller/values.yaml

    https://artifacthub.io/packages/helm/aws/aws-load-balancer-controller


# Docker Image for LB ingress controller

###### Instructions to upload LB ingress controller Docker image to AWS ECR

Step1: Get the latest docker image from this link

        https://github.com/aws/eks-charts/blob/master/stable/aws-load-balancer-controller/values.yaml

Step2: Download the docker image to your local Mac/Laptop

        $ aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin 602401143452.dkr.ecr.us-west-2.amazonaws.com

        $ docker pull 602401143452.dkr.ecr.us-west-2.amazonaws.com/amazon/aws-load-balancer-controller:v2.2.1

Step3: Retrieve an authentication token and authenticate your Docker client to your registry. Use the AWS CLI:

        $ aws ecr get-login-password --region eu-west-1 | docker login --username AWS --password-stdin <account id>.dkr.ecr.eu-west-1.amazonaws.com

Step4: Create an ECR repo for LB ingress controller if you don't have one

        $ aws ecr create-repository \
              --repository-name amazon/aws-load-balancer-controller \
              --image-scanning-configuration scanOnPush=true

Step5: After the build completes, tag your image so, you can push the image to this repository:

        $ docker tag 602401143452.dkr.ecr.us-west-2.amazonaws.com/amazon/aws-load-balancer-controller:v2.2.1 <accountid>.dkr.ecr.eu-west-1.amazonaws.com/amazon/aws-load-balancer-controller:v2.2.1

Step6: Run the following command to push this image to your newly created AWS repository:

        $ docker push <accountid>.dkr.ecr.eu-west-1.amazonaws.com/amazon/aws-load-balancer-controller:v2.2.1


#### AWS Service annotations for LB Ingress Controller
Here is the link to get the AWS ELB [service annotations](https://kubernetes-sigs.github.io/aws-load-balancer-controller/latest/guide/service/annotations/) for LB Ingress controller


<!--- BEGIN_TF_DOCS --->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_helm_addon"></a> [helm\_addon](#module\_helm\_addon) | ../helm-addon | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.aws_load_balancer_controller](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy_document.aws_lb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_addon_context"></a> [addon\_context](#input\_addon\_context) | Input configuration for the addon | <pre>object({<br>    aws_caller_identity_account_id = string<br>    aws_caller_identity_arn        = string<br>    aws_eks_cluster_endpoint       = string<br>    aws_partition_id               = string<br>    aws_region_name                = string<br>    eks_cluster_id                 = string<br>    eks_oidc_issuer_url            = string<br>    eks_oidc_provider_arn          = string<br>    tags                           = map(string)<br>  })</pre> | n/a | yes |
| <a name="input_helm_config"></a> [helm\_config](#input\_helm\_config) | Helm provider config for the aws\_load\_balancer\_controller. | `any` | `{}` | no |
| <a name="input_irsa_iam_permissions_boundary"></a> [irsa\_iam\_permissions\_boundary](#input\_irsa\_iam\_permissions\_boundary) | IAM Policy ARN for IRSA IAM role permissions boundary | `string` | `""` | no |
| <a name="input_manage_via_gitops"></a> [manage\_via\_gitops](#input\_manage\_via\_gitops) | Determines if the add-on should be managed via GitOps. | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_argocd_gitops_config"></a> [argocd\_gitops\_config](#output\_argocd\_gitops\_config) | Configuration used for managing the add-on with ArgoCD |
| <a name="output_ingress_name"></a> [ingress\_name](#output\_ingress\_name) | AWS LoadBalancer Controller Ingress Name |
| <a name="output_ingress_namespace"></a> [ingress\_namespace](#output\_ingress\_namespace) | AWS LoadBalancer Controller Ingress Namespace |

<!--- END_TF_DOCS --->
