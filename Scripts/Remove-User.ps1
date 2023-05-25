<#
.NOTES
    *****************************************************************************
    ETML
    Name:	Remove-User.ps1
    Author:	Sylvain Philipona
    Date:	25.05.2023
 	*****************************************************************************
    Modifications
 	Date  : 
 	Author: 
 	Reason: 
 	*****************************************************************************
.SYNOPSIS
    Delete an user from the AD
 	
.DESCRIPTION
    Search and delete a specified user in the active directory
  	
.PARAMETER Login
    The samAccountName of the user to delete

.OUTPUTS
	- returns True or False depending on whether the account exists and was deleted or not

.EXAMPLE
    .\Remove-User.ps1 -Login "sylphilipon"

    True

#>

##### Script parameters #####

param(
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$Login
)

##### Script logic #####

# Get the ad user
$adUser = $Login | Get-ADUser -ErrorAction SilentlyContinue

# Check if the ad user exists
if(!($adUser)){
    return $false
}

# Delete the ad user
$adUser | Remove-ADUser -Confirm:$false

return $true