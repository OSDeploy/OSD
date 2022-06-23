variable "osdcloud_containers" {
    description = "List of containers to create for OSDCloud"
    type = list
}
variable "osdscript_containers" {
    description = "List of containers to create for OSDScripts"
    type = list
}
variable "osdcloud_resourcegroup" {
    description = " Name for the resource group"
    type = string
}
variable "osdcloud_StorageAccountOSDCloud" {
    description = "The name of the storage account for OSDCloud"
    type = string
}
 variable "osdcloud_StorageAccountOSDScripts" {
    description = "The name of the storage account for OSDScripts"
    type = string   
 }   
variable "osdcloud_Location" {
    description = "Select your Azure region"
    type = string

 validation {
    condition = contains(
      ["eastasia", "southeastasia", "centralus","eastus","eastus2","westus","northcentralus","southcentralus","northeurope","westeurope","japanwest","japaneast","brazilsouth","australiaeast","australiasoutheast","southindia","centralindia","westindia","canadacentral","canadaeast","uksouth","ukwest","westcentralus","germanywestcentral","norwaywest","norwayeast","brazilsoutheast","westus3","swedencentral"],
      var.osdcloud_Location
    )
    error_message = "Err: This location is not valid for Azure."
  }
}
variable "subscription_id" {
    description = " your Azure subscription id"
    type = string
}

variable "technicien_id" {
    description = " your AzureAD User Id, it can only connect to storage account download and list objects"
    type = string
}
variable "tenant_id" {
    description = " your Azure tenant id"
    type = string
}