provider "azurerm" {
  features {}
}

# Get current Azure client details
data "azurerm_client_config" "current" {}

# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "db-demo-tf"
  location = "Central India"
}

# SQL Server
resource "azurerm_mssql_server" "sqlserver" {
  name                         = "kaviya-sql-server-tf12345"
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = azurerm_resource_group.rg.location
  version                      = "12.0"
  administrator_login          = "sqladmin"
  administrator_login_password = var.admin_password
}

# SQL Database
resource "azurerm_mssql_database" "db" {
  name      = "kaviya-db-tf"
  server_id = azurerm_mssql_server.sqlserver.id
  sku_name  = "Basic"
}

# Firewall Rule (Allow Azure Services)
resource "azurerm_mssql_firewall_rule" "rule" {
  name             = "AllowAzure"
  server_id        = azurerm_mssql_server.sqlserver.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

# Key Vault
resource "azurerm_key_vault" "kv" {
  name                        = "kaviya-kv-tf12345"
  location                    = azurerm_resource_group.rg.location
  resource_group_name         = azurerm_resource_group.rg.name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"
}

# Store password in Key Vault
resource "azurerm_key_vault_secret" "db_password" {
  name         = "sql-password"
  value        = var.admin_password
  key_vault_id = azurerm_key_vault.kv.id
}

# Role Assignment (RBAC)
resource "azurerm_role_assignment" "rbac" {
  scope                = azurerm_resource_group.rg.id
  role_definition_name = "Reader"
  principal_id         = data.azurerm_client_config.current.object_id
}
