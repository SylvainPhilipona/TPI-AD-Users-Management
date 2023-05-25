<#
.NOTES
    *****************************************************************************
    ETML
    Name:	Disable-User.ps1
    Author:	Sylvain Philipona
    Date:	25.05.2023
 	*****************************************************************************
    Modifications
 	Date  : 
 	Author: 
 	Reason: 
 	*****************************************************************************
.SYNOPSIS
    Disable an user from the AD
 	
.DESCRIPTION
    Search and disable a specified user in the active directory
  	
.PARAMETER Login
    The samAccountName of the user to disable

.OUTPUTS
	- returns True or False depending on whether the account exists and was disabled or not

.EXAMPLE
    .\Disable-User.ps1 -Login "sylphilipon"

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

# Disable the ad user
$adUser | Disable-ADAccount -Confirm:$false

return $true