# #############################################
# # kubernetes.tf
# # - Auth for Kubernetes + Helm providers (EKS)
# # - EKS Access Entry for GitHub Actions role
# # - (No risky cluster-admin bindings for service accounts)
# #############################################
 
# terraform {
#   required_providers {
#     aws = {
#       source  = "hashicorp/aws"
#       version = ">= 5.0"
#     }
#     kubernetes = {
#       source  = "hashicorp/kubernetes"
#       version = ">= 2.20"
#     }
#     helm = {
#       source  = "hashicorp/helm"
#       version = ">= 2.10"
#     }
#   }
# }
 
# ########################
# # Variables
# ########################
# variable "cluster_name" {
#   description = "EKS cluster name"
#   type        = string
# }
 
# variable "region" {
#   description = "AWS region"
#   type        = string
# }
 
# variable "github_actions_role_arn" {
#   description = "IAM Role ARN assumed by GitHub Actions via OIDC (role-to-assume)"
#   type        = string
# }
 
# ########################
# # Data sources: EKS cluster + auth token
# ########################
# data "aws_eks_cluster" "this" {
#   name = var.cluster_name
# }
 
# data "aws_eks_cluster_auth" "this" {
#   name = var.cluster_name
# }
 
# ########################
# # Kubernetes provider (NO kubeconfig / NO exec)
# ########################
# provider "kubernetes" {
#   host                   = data.aws_eks_cluster.this.endpoint
#   cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
#   token                  = data.aws_eks_cluster_auth.this.token
# }
 
# ########################
# # Helm provider (uses same auth)
# ########################
# provider "helm" {
#   kubernetes {
#     host                   = data.aws_eks_cluster.this.endpoint
#     cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
#     token                  = data.aws_eks_cluster_auth.this.token
#   }
# }
 
# #########################################################
# # EKS Access: Allow GitHub Actions role to access cluster
# # This is REQUIRED so Terraform can create Helm/K8s resources
# #########################################################
 
# # Creates an access entry for the IAM role that runs Terraform in CI
# resource "aws_eks_access_entry" "github_actions" {
#   cluster_name  = var.cluster_name
#   principal_arn = var.github_actions_role_arn
#   type          = "STANDARD"
# }
 
# # Grants cluster-admin permissions to that role
# resource "aws_eks_access_policy_association" "github_actions_cluster_admin" {
#   cluster_name  = var.cluster_name
#   principal_arn = var.github_actions_role_arn
#   policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
 
#   access_scope {
#     type = "cluster"
#   }
 
#   depends_on = [aws_eks_access_entry.github_actions]
# }
 
# #########################################################
# # OPTIONAL: If you still need an IAM user as cluster admin
# # (Not recommended for CI; Access Entry for roles is better)
# #########################################################
# # variable "cluster_admin_user_arn" {
# #   description = "IAM User ARN to grant EKS admin access"
# #   type        = string
# #   default     = null
# # }
# #
# # resource "aws_eks_access_entry" "cluster_admin_user" {
# #   count        = var.cluster_admin_user_arn == null ? 0 : 1
# #   cluster_name  = var.cluster_name
# #   principal_arn = var.cluster_admin_user_arn
# #   type          = "STANDARD"
# # }
# #
# # resource "aws_eks_access_policy_association" "cluster_admin_user_admin" {
# #   count        = var.cluster_admin_user_arn == null ? 0 : 1
# #   cluster_name  = var.cluster_name
# #   principal_arn = var.cluster_admin_user_arn
# #   policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
# #
# #   access_scope {
# #     type = "cluster"
# #   }
# #
# #   depends_on = [aws_eks_access_entry.cluster_admin_user]
# # }
 
# #########################################################
# # IMPORTANT NOTES:
# # 1) REMOVE your kubernetes_cluster_role_binding for ALB SA.
# #    Helm chart creates required RBAC.
# # 2) If you apply everything in one run, make ALB Helm release
# #    depend on aws_eks_access_policy_association.github_actions_cluster_admin
# #########################################################
 