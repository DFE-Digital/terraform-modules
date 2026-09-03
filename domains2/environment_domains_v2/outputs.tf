output "endpoints" {
  description = "Map of Front Door endpoints"
  value = {
    for key, endpoint in azurerm_cdn_frontdoor_endpoint.main : key => {
      id        = endpoint.id
      name      = endpoint.name
      host_name = endpoint.host_name
    }
  }
}

output "custom_domains" {
  description = "Map of custom domains"
  value = {
    for key, domain in azurerm_cdn_frontdoor_custom_domain.main : key => {
      id                 = domain.id
      name               = domain.name
      host_name          = domain.host_name
      validation_token   = domain.validation_token
      expiration_date    = domain.expiration_date
    }
  }
}

output "routes" {
  description = "Map of Front Door routes"
  value = {
    for key, route in azurerm_cdn_frontdoor_route.main : key => {
      id                = route.id
      name              = route.name
      patterns_to_match = route.patterns_to_match
      endpoint_name     = azurerm_cdn_frontdoor_endpoint.main[local.domain_to_endpoint_map[key]].name
    }
  }
}

output "dns_records" {
  description = "DNS records created"
  value = {
    cname_records = {
      for key, record in azurerm_dns_cname_record.main : key => {
        name   = record.name
        zone   = record.zone_name
        record = record.record
      }
    }
    a_records = {
      for key, record in azurerm_dns_a_record.apex : key => {
        name = record.name
        zone = record.zone_name
      }
    }
    txt_records = merge(
      {
        for key, record in azurerm_dns_txt_record.validation : key => {
          name = record.name
          zone = record.zone_name
        }
      },
      {
        for key, record in azurerm_dns_txt_record.validation_apex : key => {
          name = record.name
          zone = record.zone_name
        }
      }
    )
  }
}

output "endpoint_sharing_strategy" {
  description = "The endpoint sharing strategy used"
  value       = var.endpoint_configuration.strategy
}

output "endpoint_groups" {
  description = "How domains are grouped into endpoints"
  value = {
    for ep_key, domains in local.endpoint_groups : ep_key => [
      for d in domains : "${d.name}.${d.zone}"
    ]
  }
}