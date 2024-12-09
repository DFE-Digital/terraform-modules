# AKS Cluster Data

Terraform module for managing information about the cluster.

## Terraform documentation
For the list of requirement, inputs, outputs, resources... check the [terraform module documentation](tfdocs).

## Usage

```terraform
module "cluster_data" {
  source = "git::https://github.com/DFE-Digital/terraform-modules.git//aks/cluster_data?ref=stable"
  name   = var.cluster
}

provider "kubernetes" {
  host                   = module.cluster_data.kubernetes_host
  client_certificate     = module.cluster_data.kubernetes_client_certificate
  client_key             = module.cluster_data.kubernetes_client_key
  cluster_ca_certificate = module.cluster_data.kubernetes_cluster_ca_certificate
}
```

## Outputs

### `configuration_map`

The configuration map for the cluster, an object with the following fields structure:

```terraform
object({
  resource_group_name = string
  resource_prefix     = string
  dns_zone_prefix     = optional(string)
  cpu_min             = number
})
```

### `kubernetes_host`

The host to use to connect to the Kubernetes cluster.

### `kubernetes_id`

The ID of the Kubernetes Managed Cluster.

### `kubernetes_client_certificate`

The client certificate to use to connect to the Kubernetes cluster. `null` when the cluster uses Azure RBAC.

### `kubernetes_client_key`

The client key to use to connect to the Kubernetes cluster. `null` when the cluster uses Azure RBAC.

### `kubenetes_cluster_ca_certificate`

The client cluster CA certificate to use to connect to the Kubernetes cluster.

### `azure_RBAC_enabled`

`true` if the cluster uses Azure RBAC

### `kubelogin_args`

Arguments for [kubelogin](https://azure.github.io/kubelogin/) to authenticate to a cluster using Azure RBAC. Used in the kubernetes provider configuration:

```hcl
provider "kubernetes" {
  host                   = module.cluster_data.kubernetes_host
  client_certificate     = module.cluster_data.kubernetes_client_certificate
  client_key             = module.cluster_data.kubernetes_client_key
  cluster_ca_certificate = module.cluster_data.kubernetes_cluster_ca_certificate

  dynamic "exec" {
    for_each = module.cluster_data.azure_RBAC_enabled ? [1] : []
    content {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "kubelogin"
      args        = module.cluster_data.kubelogin_args
    }
  }
}
```

### `ingress_domain`

Generic domain for all web applications on the cluster.

For example the test cluster ingress domain is "test.teacherservices.cloud". The web application apply-review-1234 full domain is:

`<app name>.<ingress domain>` or
"apply-review-1234.test.teacherservices.cloud"
