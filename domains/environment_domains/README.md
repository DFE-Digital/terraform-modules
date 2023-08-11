# Environment domains

Create a custom domain per environment. The domain is created on Azure front door and the corresponding DNS records are created in the Azure DNS zone. Front door and DNS zone are created by the [domains/infrastructure module](../infrastructure/).

It supports both subdomains and the apex domain (domain with the same name as the DNS zone).

Certificates managed by front door are automatically generated and renewed before expiration. Only the apex domain certificate is not automatically renewed. It is strongly suggested to set up SSL monitoring using the [monitoring/statuscake module](../../monitoring/statuscake/).

## Usage

```terraform
module "domains" {
  source              = "./vendor/modules/domains//domains/environment_domains"
  zone                = "my-teacher-service.education.gov.uk"
  front_door_name     = "s189p01-mts-domains-fd"
  resource_group_name = "s189p01-mts-domains-rg"
  domains             = ["apex", "www"]
  environment         = "pd"
  host_name           = "my-teacher-service-roduction.teacherservices.cloud"
  cached_paths        = "/assets/*"
}
```
