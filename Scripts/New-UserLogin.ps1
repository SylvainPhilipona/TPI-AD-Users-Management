<#
.NOTES
    *****************************************************************************
    ETML
    Name:	New-UserLogin.ps1
    Author:	Sylvain Philipona
    Date:	10.05.2023
 	*****************************************************************************
    Modifications
 	Date  : 
 	Author: 
 	Reason: 
 	*****************************************************************************
.SYNOPSIS
    Generate a login name based on a firstname and lastname
 	
.DESCRIPTION
    The login name is generated from the first 3 characters of the first name and the first 8 characters (maximum) of the last name
  	
.PARAMETER FirstName
    The firstname of the user

.PARAMETER LastName
    The lastname of the user

.OUTPUTS
	- The generated login from the firstname and lastname

.EXAMPLE
    .\New-UserLogin.ps1 -FirstName "John" -LastName "Doe"
    johdoe
 	
.EXAMPLE
    .\New-UserLogin.ps1 -FirstName "Sylvain" -LastName "Philipona"
    sylphilipon
#>

##### Script parameters #####

param(
    [ValidateNotNullOrEmpty()]
    [string]$FirstName,

    [ValidateNotNullOrEmpty()]
    [string]$LastName
)

##### Constants #####
$FIRSTNAME_MAX_CHARS = 3
$LASTNAME_MAX_CHARS = 8

##### Variables #####

$login = ""

##### Script logic #####

# Get the first 3 characters of the firstname
# If the firstname do not contains at least 3 characters, all the firstname is taken
if ($FirstName.Length -gt $FIRSTNAME_MAX_CHARS) {
    # Add to the login string the 3 first chars
    $login += $FirstName.substring(0,$FIRSTNAME_MAX_CHARS)
} else {
    # Add to the login string the entire firstname
    $login += $FirstName
}

# Get the 8 first chars of the lastname
# If the lastname do not contains at least 8 chars, all the lastname is taken
if ($LastName.Length -gt $LASTNAME_MAX_CHARS) {
    # Add to the login string the 8 first chars
    $login += $LastName.substring(0, $LASTNAME_MAX_CHARS)
} else {
    # Add to the login string the entire lastName
    $login += $LastName
}

# Put the login in lowercase
$login = $login.ToLower()

# Return the formatted login
return $login