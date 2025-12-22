# provider "kubernetes" {
#   host                   = data.aws_eks_cluster.cluster.endpoint
#   cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
#   token                  = data.aws_eks_cluster_auth.cluster.token
# }

# provider "helm" {
#   kubernetes {
#     host                   = data.aws_eks_cluster.cluster.endpoint
#     cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
#     token                  = data.aws_eks_cluster_auth.cluster.token
#   }
# }


# resource "kubernetes_namespace" "mattermost" {
#   depends_on = [aws_db_instance.mattermost_rds]

#   metadata {
#     name = var.k8s_namespace
#   }
# }

# resource "helm_release" "mattermost" {
#   depends_on = [aws_db_instance.mattermost_rds]

#   name       = "mattermost"
#   namespace  = kubernetes_namespace.mattermost.metadata[0].name
#   repository = "https://helm.mattermost.com"
#   chart      = "mattermost-team-edition"
#   version    = "6.6.0"

#   values = [
#     file("files/values.yaml") # optional custom values
#   ]
# }
