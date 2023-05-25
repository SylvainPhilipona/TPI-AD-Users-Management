<#
.NOTES
    *****************************************************************************
    ETML
    Name:	Remove-HomeDirectory.ps1
    Author:	Sylvain Philipona
    Date:	25.05.2023
 	*****************************************************************************
    Modifications
 	Date  : 
 	Author: 
 	Reason: 
 	*****************************************************************************
.SYNOPSIS
    Delete the home directory of a ad user
 	
.DESCRIPTION
    Delete and unmap the user home directory folder
  	
.PARAMETER Username
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
    [string]$Username
)

##### Script logic #####

# Check if the user exists
$adUser = Get-ADUser -Filter { SamAccountName -eq $Username } -Properties HomeDirectory
if(!($adUser)){
    Write-Error "The user '$Username' not exists"
    return $false
}

# Check if the ad user has a home directory
if(!($adUser.HomeDirectory)){
    Write-Error "The user '$Username' not have a home directory"
    return $false
}

# Remove the home directory of the user
# Unmapping the home directory in the ad user
$adUser.HomeDirectory | Remove-Item -Recurse -Force -Confirm:$false
$adUser | Set-ADUser -HomeDirectory $null -HomeDrive $null

return $true