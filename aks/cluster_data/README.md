# AKS Cluster Data

Terraform module for managing information about the cluster.

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

### `kubernetes_client_certificate`

The client certificate to use to connect to the Kubernetes cluster.

### `kubernetes_client_key`

The client key to use to connect to the Kubernetes cluster.

### `kubenetes_cluster_ca_certificate`

The client cluster CA certificate to use to connect to the Kubernetes cluster.
