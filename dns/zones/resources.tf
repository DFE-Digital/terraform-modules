# Zone

resource "azurerm_dns_zone" "dns_zone" {
  for_each = var.hosted_zone

  name                = each.key
  resource_group_name = each.value.resource_group_name

  tags = var.tags

  lifecycle { ignore_changes = [tags] }
}

# CAA record

locals {
  # caa_records is deprecated. Use caa_record_list instead
  caa_records = flatten([
    for zone_name, zone_cfg in var.hosted_zone : [
      for record_name, record_cfg in try(zone_cfg["caa_records"], {}) : {
        record_name         = record_name
        zone_name           = zone_name
        resource_group_name = zone_cfg["resource_group_name"]
        flags               = record_cfg["flags"]
        tag                 = record_cfg["tag"]
        value               = record_cfg["value"]
      }
    ]
  ])

  hosted_zone_with_caa_record_list = {
    for zone_name, zone_cfg in var.hosted_zone :
    zone_name => zone_cfg
    if length(try(zone_cfg.caa_record_list, [])) > 0
  }
}

# caa_records is deprecated. Use caa_record_list instead
resource "azurerm_dns_caa_record" "caa_records" {
  for_each = {
    for zone in local.caa_records : "${zone.zone_name}.${zone.record_name}" => zone
  }

  name                = each.value.record_name
  zone_name           = each.value.zone_name
  resource_group_name = each.value.resource_group_name
  ttl                 = 300

  record {
    flags = each.value.flags
    tag   = each.value.tag
    value = each.value.value
  }

  depends_on = [
    azurerm_dns_zone.dns_zone
  ]

}

resource "azurerm_dns_caa_record" "caa_record_list" {
  for_each = local.hosted_zone_with_caa_record_list

  name                = "@"
  zone_name           = each.key
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

  depends_on = [
    azurerm_dns_zone.dns_zone
  ]

}

# TXT record
locals {
  # Create a list of maps. Each map contains the zone, the TXT record name and value, and other required fields
  txt_records = flatten([
    for zone_name, zone_cfg in var.hosted_zone : [
      for record_name, record_cfg in try(zone_cfg["txt_records"], []) : {
        record_name         = record_name
        zone_name           = zone_name
        resource_group_name = zone_cfg["resource_group_name"]
        value               = record_cfg["value"]
      }
    ]
  ])

  # Create a list of maps. Each map contains the zone, the TXT record name and list of values, and other required fields
  txt_record_lists = flatten([
    for zone_name, zone_cfg in var.hosted_zone : [
      for record_name, record_cfg in try(zone_cfg["txt_record_lists"], []) : {
        record_name         = record_name
        zone_name           = zone_name
        resource_group_name = zone_cfg["resource_group_name"]
        txt_record_list     = record_cfg
      }
    ]
  ])
}

# Create TXT records, each one with a record name a single value
resource "azurerm_dns_txt_record" "txt_records" {
  for_each = {
    for zone in local.txt_records : "${zone.zone_name}.${zone.record_name}" => zone
  }

  name                = each.value.record_name
  zone_name           = each.value.zone_name
  resource_group_name = each.value.resource_group_name
  ttl                 = 300

  record {
    value = each.value.value
  }

  depends_on = [
    azurerm_dns_zone.dns_zone
  ]

}

# Create TXT records, each one with a record name and a list of values
resource "azurerm_dns_txt_record" "txt_record_list" {
  for_each = {
    for zone in local.txt_record_lists : "${zone.zone_name}.${zone.record_name}" => zone
  }

  name                = each.value.record_name
  zone_name           = each.value.zone_name
  resource_group_name = each.value.resource_group_name
  ttl                 = 300

  dynamic "record" {
    for_each = toset(each.value.txt_record_list)
    content {
      value = record.value
    }
  }

  depends_on = [
    azurerm_dns_zone.dns_zone
  ]

}
