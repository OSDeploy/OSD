resource "azurerm_resource_group" "RessourceGroup" {
    location    = var.osdcloud_Location
    name      = var.osdcloud_resourcegroup
}

resource "azurerm_storage_account" "OSDCloud" {
  account_replication_type = "LRS"
  account_tier             = "Standard"
  location                 = var.osdcloud_Location
  name                     = var.osdcloud_StorageAccountOSDCloud
  resource_group_name      = var.osdcloud_resourcegroup
  access_tier              = "Hot"
  min_tls_version          = "TLS1_2"
  account_kind             = "StorageV2"
  shared_access_key_enabled = true
  allow_nested_items_to_be_public = true
    blob_properties {
      change_feed_enabled = true
    }
  
  tags = {
    OSDCloud = "production"
  }
  depends_on = [
    azurerm_resource_group.RessourceGroup,
  ]
}
resource "azurerm_storage_account" "OSDScripts" {
    depends_on = [
    azurerm_resource_group.RessourceGroup,
  ]

  account_replication_type = "LRS"
  account_tier             = "Standard"
  location                 = var.osdcloud_Location
  name                     = var.osdcloud_StorageAccountOSDScripts
  resource_group_name      = var.osdcloud_resourcegroup
  min_tls_version          = "TLS1_2"
  access_tier              = "Hot"
  account_kind             = "StorageV2"
  shared_access_key_enabled = true
  allow_nested_items_to_be_public = true
    blob_properties {
      change_feed_enabled = true
    }
  tags = {
    OSDScripts = "powershell"
  }
}

resource "azurerm_storage_container" "ContainerOSDCloud" {
   depends_on = [
    azurerm_resource_group.RessourceGroup,
    azurerm_storage_account.OSDCloud,
  ]

  count = length(var.osdcloud_containers)
  name                  = var.osdcloud_containers[count.index]
  storage_account_name  = azurerm_storage_account.OSDCloud.name
  container_access_type = "container"
}

resource "azurerm_storage_container" "ContainerOSDScripts" {
  count = length(var.osdscript_containers)
  name                  = var.osdscript_containers[count.index]
  storage_account_name  = azurerm_storage_account.OSDScripts.name
  container_access_type = "container"
}

resource "azurerm_role_assignment" "RBAC_OSDCloud" {
  scope                = azurerm_storage_account.OSDCloud.id
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = var.technicien_id
}
resource "azurerm_role_assignment" "RBAC_OSDScripts" {
  scope                = azurerm_storage_account.OSDScripts.id
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = var.technicien_id
}
