provider "azurerm" {
  features {}
}

resource "random_string" "suffix" {
  length  = 4
  special = false
  upper   = false
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "rg" {
  name     = "db-demo-tf-${random_string.suffix.result}"
  location = "Central India"
}

resource "azurerm_mssql_server" "sqlserver" {
  name                         = "kaviya-sql-${random_string.suffix.result}"
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = azurerm_resource_group.rg.location
  version                      = "12.0"
  administrator_login          = "sqladmin"
  administrator_login_password = var.admin_password
}

resource "azurerm_mssql_database" "db" {
  name      = "kaviya-db-tf"
  server_id = azurerm_mssql_server.sqlserver.id
  sku_name  = "Basic"
}

resource "azurerm_mssql_firewall_rule" "rule" {
  name             = "AllowAzure"
  server_id        = azurerm_mssql_server.sqlserver.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

resource "azurerm_key_vault" "kv" {
  name                = "kaviya-kv-${random_string.suffix.result}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"
}
