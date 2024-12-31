# AKS Cluster Data

Terraform module for managing information about the cluster.

## Terraform documentation
For the list of requirement, inputs, outputs, resources... check the [terraform module documentation](tfdocs.md).

## Usage

```terraform
module "cluster_data" {
  source = "git::https://github.com/DFE-Digital/terraform-modules.git//aks/cluster_data?ref=stable"
  name   = var.cluster
}

locals {
  web_app_aks_domain = "teaching-vacancies-${var.environment}.${module.cluster_data.ingress_domain}"
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

### `kubernetes_cluster_ca_certificate`

The client cluster CA certificate to use to connect to the Kubernetes cluster.

### `azure_RBAC_enabled`

`true` if the cluster uses Azure RBAC

### `kubelogin_args`

Arguments for [kubelogin](https://azure.github.io/kubelogin/) to authenticate to a cluster using Azure RBAC. Used in the kubernetes provider configuration:

```terraform
provider "kubernetes" {
  host                   = module.cluster_data.kubernetes_host
  cluster_ca_certificate = module.cluster_data.kubernetes_cluster_ca_certificate

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "kubelogin"
    args        = module.cluster_data.kubelogin_args
  }
}
```

Supports 3 kubelogin authentication modes:
- `azurecli` when running locally
- `spn` when running in Github actions using an Azure service principal secret (deprecated)
- `workloadidentity` when running in Github actions using OIDC (preferred)

The mode is automatically selected based on standard environment variables.

### `ingress_domain`

Generic domain for all web applications on the cluster.

For example the test cluster ingress domain is "test.teacherservices.cloud". The web application apply-review-1234 full domain is:

`<app name>.<ingress domain>` or
`apply-review-1234.test.teacherservices.cloud`
