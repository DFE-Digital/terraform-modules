mock_provider "azurerm" {}

variables {
  azure_resource_prefix       = "test"
  service_short               = "svc"
  environment                 = "test"
  location                    = "uksouth"
  resource_group_name         = "test-rg"
  create_standard_storage_account = false
}

run "no_connections" {
  command = plan

  assert {
    condition     = length(output.sql_private_endpoint_names) == 0
    error_message = "No SQL private endpoints should be created."
  }

  assert {
    condition     = length(output.postgresql_private_endpoint_names) == 0
    error_message = "No PostgreSQL private endpoints should be created."
  }
}

run "sql_private_endpoint" {
  command = plan

  variables {
    sql_server_connections = [
      {
        name                            = "primary-sql"
        connection_string_secret_name   = "primary-sql-connection"
        create_private_endpoint         = true
        private_link_target_resource_id = "/subscriptions/test/resourceGroups/test-rg/providers/Microsoft.Sql/servers/test-sql"
      }
    ]
  }

  assert {
    condition     = output.sql_private_endpoint_names == ["primary-sql"]
    error_message = "The SQL private endpoint was not created."
  }
}

run "postgresql_without_private_endpoint" {
  command = plan

  variables {
    postgresql_connections = [
      {
        name                            = "primary-postgres"
        connection_string_secret_name   = "primary-postgres-connection"
        create_private_endpoint         = false
      }
    ]
  }

  assert {
    condition     = length(output.postgresql_private_endpoint_names) == 0
    error_message = "A PostgreSQL private endpoint should not be created."
  }
}

run "multiple_connection_types" {
  command = plan

  variables {
    sql_server_connections = [
      {
        name                            = "sql-one"
        connection_string_secret_name   = "sql-one-connection"
        create_private_endpoint         = true
        private_link_target_resource_id = "/subscriptions/test/resourceGroups/test-rg/providers/Microsoft.Sql/servers/sql-one"
      },
      {
        name                            = "sql-two"
        connection_string_secret_name   = "sql-two-connection"
        create_private_endpoint         = true
        private_link_target_resource_id = "/subscriptions/test/resourceGroups/test-rg/providers/Microsoft.Sql/servers/sql-two"
      }
    ]

    postgresql_connections = [
      {
        name                            = "postgres-one"
        connection_string_secret_name   = "postgres-one-connection"
        create_private_endpoint         = true
        private_link_target_resource_id = "/subscriptions/test/resourceGroups/test-rg/providers/Microsoft.DBforPostgreSQL/flexibleServers/postgres-one"
      }
    ]
  }

  assert {
    condition     = output.sql_private_endpoint_names == ["sql-one", "sql-two"]
    error_message = "Unexpected SQL private endpoint names."
  }

  assert {
    condition     = output.postgresql_private_endpoint_names == ["postgres-one"]
    error_message = "Unexpected PostgreSQL private endpoint names."
  }
}
