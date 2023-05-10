<#
.NOTES
    *****************************************************************************
    ETML
    Name:	New-RandomPassword.ps1
    Author:	Sylvain Philipona
    Date:	10.05.2023
 	*****************************************************************************
    Modifications
 	Date  : 
 	Author: 
 	Reason: 
 	*****************************************************************************
.SYNOPSIS
    Generates a random password
 	
.DESCRIPTION
    Generates a random password according to the length defined in parameters
  	
.PARAMETER Length
    This is the length of the password that will be generated

.PARAMETER ExcludeSimilar
    When this parameter is specified, the password will not contain characters that can be confused with others

.OUTPUTS
	- A random generated password

.EXAMPLE
    .\New-RandomPassword.ps1 -ExcludeSimilar -Length 16
 	!qm@jcfbyN9wv6PF
.EXAMPLE
    .\New-RandomPassword.ps1
    5MT&C$b5tiRW
.LINK
    https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/get-random?view=powershell-7.3
#>

##### Script parameters #####

param(
    [ValidateRange(1, [int]::MaxValue)]
    [int]$Length = 12,

    [Parameter(Mandatory=$false)]
    [switch]$ExcludeSimilar
)

##### Constants #####

$UPPER = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
$LOWER = "abcdefghijklmnopqrstuvwxyz"
$NUMBERS = "0123456789"
$SPECIALS = "!#$&*-/=?@_"
$SIMILAR = "IlL10Oo"

##### Variables #####

$all = $UPPER + $LOWER + $NUMBERS + $SPECIALS
$password = ""

##### Script logic #####

# Generate the password with the length input in arguments
while ($password.Length -lt $Length){
    # Generate a random number from 0 to the max index of the 'all' variable
    $randomIndex = Get-Random -Minimum 0 -Maximum ($all.Length-1)

    # Get the char from the generated index and add it to the password
    $randomChar = $all[$randomIndex]

    # Check if the exclude similar param is specified
    if($ExcludeSimilar){

        # If the generated character is in the list of similars, the character is regenerated
        if(!($SIMILAR.Contains($randomChar))){

            # Add the generated char to the password
            $password += $randomChar
        }
    }
    else{
        # Add the generated char to the password
        $password += $randomChar
    }
}

# Return the password
return $password
