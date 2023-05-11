<#
.NOTES
    *****************************************************************************
    ETML
    Name:	Find-User.ps1
    Author:	Sylvain Philipona
    Date:	11.05.2023
 	*****************************************************************************
    Modifications
 	Date  : 
 	Author: 
 	Reason: 
 	*****************************************************************************
.SYNOPSIS
    Search if a user exists in the AD
 	
.DESCRIPTION
    Check if a user exists in the Active Directory.
    The search is carried out by first and last name
  	
.PARAMETER FirstName
    The first name of the account to verify

.PARAMETER LastName
    The last name of the account to verify

.OUTPUTS
	- returns True or False depending on whether the account exists or not

.EXAMPLE
    .\Find-User.ps1 -FirstName "Sylvain" -LastName "Philipona"
    True

.LINK
    https://learn.microsoft.com/en-us/powershell/module/activedirectory/get-aduser?view=windowsserver2022-ps
#>

##### Script parameters #####

param(
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$FirstName,

    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$LastName
)

##### Script logic #####

# Find an Ad User on the AD with the specified FirstName and LastName
$adUser = (Get-Aduser -Filter {GivenName -eq $FirstName -and sn -eq $LastName})

# If the AD do not find any users, the variable is null
if(!$adUser){
    return $false
}

return $true