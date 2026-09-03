# DNS Zones
resource "azurerm_dns_zone" "main" {
  for_each            = var.hosted_zones
  name                = each.value.zone_name
  resource_group_name = each.value.resource_group_name
  tags                = var.tags

  lifecycle { 
    ignore_changes = [tags] 
  }
}

# CAA Records
resource "azurerm_dns_caa_record" "main" {
  for_each = {
    for zone_key, zone_cfg in var.hosted_zones :
    zone_key => zone_cfg
    if length(zone_cfg.caa_record_list) > 0
  }

  name                = "@"
  zone_name           = azurerm_dns_zone.main[each.key].name
  resource_group_name = each.value.resource_group_name
  ttl                 = 300

  dynamic "record" {
    for_each = toset(each.value.caa_record_list)
    content {
      flags = 0
      tag   = "issue"
      value = record.value
    }
  }

  depends_on = [azurerm_dns_zone.main]
}

# TXT Records
resource "azurerm_dns_txt_record" "main" {
  for_each = {
    for item in flatten([
      for zone_key, zone_cfg in local.hosted_zones_with_records : [
        for record_name, record_cfg in try(zone_cfg.txt_records, {}) : {
          key                 = "${zone_key}.${record_name}"
          zone_key            = zone_key
          record_name         = record_name
          zone_name           = zone_cfg.zone_name
          resource_group_name = zone_cfg.resource_group_name
          value               = record_cfg.value
        }
      ]
    ]) : item.key => item
  }

  name                = each.value.record_name
  zone_name           = each.value.zone_name
  resource_group_name = each.value.resource_group_name
  ttl                 = 300

  record {
    value = each.value.value
  }

  depends_on = [azurerm_dns_zone.main]
}