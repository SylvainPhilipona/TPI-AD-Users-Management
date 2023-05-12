<#
.NOTES
    *****************************************************************************
    ETML
    Name:	Find-UserLogin.ps1
    Author:	Sylvain Philipona
    Date:	12.05.2023
 	*****************************************************************************
    Modifications
 	Date  : 
 	Author: 
 	Reason: 
 	*****************************************************************************
.SYNOPSIS
    Search if a login exists in the AD
 	
.DESCRIPTION
    Check if a login exists in the Active Directory.
    The search is carried out by the samAccountName propriety

.PARAMETER Login
    The login name to verify

.OUTPUTS
	- Returns True or False depending on whether the login exists or not

.EXAMPLE
    .\Find-UserLogin.ps1 -Login "sylphilipona"

.LINK
    https://www.it-connect.fr/active-directory-samaccountname-vs-userprincipalname/
#>

##### Script parameters #####

param(
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$Login
)

##### Script logic #####

# Find an Ad User on the AD with the specified FirstName and LastName
$adUser = (Get-Aduser -Filter {samAccountName -eq $Login})

# If the AD do not find any users, the variable is null
if(!$adUser){
    return $false
}

return $true