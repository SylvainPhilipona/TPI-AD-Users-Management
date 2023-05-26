<#
.NOTES
    *****************************************************************************
    ETML
    Name:	Remove-HomeDirectory.ps1
    Author:	Sylvain Philipona
    Date:	25.05.2023
 	*****************************************************************************
    Modifications
 	Date  : 26.05.2023
 	Author: Sylvain Philipona
 	Reason: Removed errors messaged
 	*****************************************************************************
.SYNOPSIS
    Delete the home directory of a ad user
 	
.DESCRIPTION
    Delete and unmap the user home directory folder
  	
.PARAMETER Login
    The samAccountName of the user to delete the home directory

.OUTPUTS
	- True of False according to if the folder was deleted or not

.EXAMPLE
    .\Remove-HomeDirectory.ps1 -Username "sylphilipon"

    True
#>

##### Script parameters #####

param(
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$Login
)

##### Script logic #####

# Check if the user exists
$adUser = Get-ADUser -Filter { SamAccountName -eq $Login } -Properties HomeDirectory
if(!($adUser)){
    return $false
}

# Check if the ad user has a home directory
if(!($adUser.HomeDirectory)){
    return $false
}

# Remove the home directory of the user
# Unmapping the home directory in the ad user
$adUser.HomeDirectory | Remove-Item -Recurse -Force -Confirm:$false
$adUser | Set-ADUser -HomeDirectory $null -HomeDrive $null

return $true