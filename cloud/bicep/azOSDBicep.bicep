@description('Specifies the name of the Azure Storage account.')
param storageAccountName string ='osdcloudbicepdemo2'

@description('Specifies the name of the Azure Storage account.')
param StorageAccuntList string ='osdscripts2'

@description('Specifies the name of the blob for logs container.')
param containerName string = 'logs'

@description('Specifies the location in which the Azure Storage resources should be deployed.')
param location string = resourceGroup().location

@description('Specifies container object list for wim images.')
param containers object = {
  c1:{
    name: 'server'
    type: 'Container'
  }
  c2:{
    name: 'retail'
    type: 'Container'
  }
  c3:{
    name: 'insiders'
    type: 'Container'
  }
  c4:{
    name: 'driverpack'
    type: 'Container'
  }
  c5:{
    name: 'bootimage'
    type: 'Container'
  }

}
@description('Specifies container object list for powershell scripts, packages, unattend.')
param scripts object = {
  c1:{
    name: 'scripts'
    type: 'Container'
  }
  c2:{
    name: 'packages'
    type: 'Container'
  }
  c3:{
    name: 'unattend'
    type: 'Container'
  }
  c4:{
    name: 'others'
    type: 'Container'
  }
}

@description('This is the built-in Storage Blob Data Reader.')
resource StorageBlobDataReaderDefinition 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  scope: subscription()
  name: 'b7e6dc6d-f1e8-4753-8033-0f276bb0955b'
}
@description('This is the ID for the AzureADAccount who can access.')
param principalId string = '1618bbc9-bdce-45af-a3bd-a86c224d8094'

resource AzStorage 'Microsoft.Storage/storageAccounts@2021-06-01' = {
  name: storageAccountName
  location: location
  tags : {
    OSDCloud :'production' 
  }
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    allowBlobPublicAccess: true
    allowSharedKeyAccess:true
    minimumTlsVersion: 'TLS1_2'
    defaultToOAuthAuthentication: true
    
  }
}
resource AzScripts 'Microsoft.Storage/storageAccounts@2021-06-01' = {
  name: StorageAccuntList
  location: location
  tags : {
    OSDScripts :'powershell' 
  }
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    allowBlobPublicAccess: true
    allowSharedKeyAccess:true
    allowCrossTenantReplication: true
    minimumTlsVersion: 'TLS1_2'
    defaultToOAuthAuthentication: true
  }
}

resource log 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-06-01' = {
  name: '${AzStorage.name}/default/${containerName}'

}

resource containerlist 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-06-01' =[for cont in items(containers):{
  name:'${AzStorage.name}/default/${cont.value.name}'
  properties: {
    publicAccess: cont.value.type
}
}]

resource containerscriptlist 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-06-01' =[for cont in items(scripts):{
  name:'${AzScripts.name}/default/${cont.value.name}'
  properties: {
    publicAccess: cont.value.type
}
}]

resource ActivateFeedStorage 'Microsoft.Storage/storageAccounts/blobServices@2021-09-01' = {
  name: 'default'
  parent: AzStorage
  properties: {
    changeFeed: {
      enabled: true
    }
  }
}
resource ActivateFeedScript 'Microsoft.Storage/storageAccounts/blobServices@2021-09-01' = {
  name: 'default'
  parent: AzScripts
  properties: {
    changeFeed: {
      enabled: true
    }
  }
}

resource roleAssignmentAzStorage 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = {
  scope: AzStorage
  name: guid(AzStorage.id, principalId, StorageBlobDataReaderDefinition.id)
  properties: {
    roleDefinitionId: StorageBlobDataReaderDefinition.id
    principalId: principalId
    principalType: 'User'
  }
}
resource roleAssignmentAzSScripts 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = {
  scope: AzScripts
  name: guid(AzScripts.id, principalId, StorageBlobDataReaderDefinition.id)
  properties: {
    roleDefinitionId: StorageBlobDataReaderDefinition.id
    principalId: principalId
    principalType: 'User'
  }
}
