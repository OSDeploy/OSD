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
resource AzSscripts 'Microsoft.Storage/storageAccounts@2021-06-01' = {
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
  name:'${AzSscripts.name}/default/${cont.value.name}'
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
  parent: AzSscripts
  properties: {
    changeFeed: {
      enabled: true
    }
  }
}

