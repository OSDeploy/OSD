function Test-DynamicValidateSet {
<#
.SYNOPSIS
Tests DynamicValidateSet conditions.

.DESCRIPTION
Evaluates DynamicValidateSet state and returns a validation result for scripting decisions.

.EXAMPLE
Test-DynamicValidateSet
Demonstrates a common way to run Test-DynamicValidateSet.

.LINK
https://github.com/OSDeploy/OSD/tree/master/Docs

.NOTES
Author: David Segura - Recast Software
2026-07-13 - Initial help block created
2026-07-13 - Refined generated help text
#>
  [CmdletBinding()]
  param(
      #No parameters are hard coded!
  )

  DynamicParam {
          # Set the dynamic parameters' name
          $ParameterName = 'OSName'
          
          # Create the dictionary 
          $RuntimeParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary

          # Create the collection of attributes
          $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
          
          # Create and set the parameters' attributes
          $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
          $ParameterAttribute.Mandatory = $true
          $ParameterAttribute.Position = 1

          # Add the attributes to the attributes collection
          $AttributeCollection.Add($ParameterAttribute)

          # Generate and set the ValidateSet 
          $arrSet = $Global:OSDModuleResource.OSDCloud.Values.Name
          $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($arrSet)

          # Add the ValidateSet to the attributes collection
          $AttributeCollection.Add($ValidateSetAttribute)

          # Create and return the dynamic parameter
          $RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($ParameterName, [string], $AttributeCollection)
          $RuntimeParameterDictionary.Add($ParameterName, $RuntimeParameter)
          return $RuntimeParameterDictionary
  }

  begin {
      # Bind the parameter
      $OSName = $PsBoundParameters[$ParameterName]
  }

  process {
      # rest of the function in here
  }
}
