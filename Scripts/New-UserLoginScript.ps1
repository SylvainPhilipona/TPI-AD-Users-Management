<#
.NOTES
    *****************************************************************************
    ETML
    Name:	New-UserLoginScript.ps1
    Author:	Sylvain Philipona
    Date:	12.05.2023
 	*****************************************************************************
    Modifications
 	Date  : 
 	Author: 
 	Reason: 
 	*****************************************************************************
.SYNOPSIS
    Match a profession with a script
 	
.DESCRIPTION
    Match the profession of a user with a script

.PARAMETER Profession
    The profession of the user

.OUTPUTS
	- The script of the profession

.EXAMPLE
    .\New-UserLoginScript.ps1 -Profession "Ebeniste"

    BOIS.BAT

.LINK
    https://stackoverflow.com/questions/39906809/powershell-2-0-how-to-match-or-like-a-string-in-hash-table-keys

#>

##### Script parameters #####

param(
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$Profession
)

##### Script logic #####

# The truth table for the professions and the scripts
$professionsScripts = @{
    "Automaticien"      = "AM.BAT"
    "Ebeniste"          = "BOIS.BAT"
    "Menuisier"         = "BOIS.BAT"
    "Electronicien"     = "ELO.BAT"
    "Informaticien"     = "INF.BAT"
    "Mecatronicien"     = "AUTO.BAT"
    "Polymecanicien"    = "PM.BAT"
    "Pre-apprentissage" = "PAPP.BAT"
    "Technicien"        = "ES.BAT"
    "MP-TASV"           = "TH.BAT"
    "MAD"               = "TH.BAT"
    "Technisceniste"    = "TECHNI.BAT"
}

# Go through the whole truth table
foreach($script in $professionsScripts.GetEnumerator()){

    # Check if the profession in params match the element in the truth table
    if($Profession -like "*$($script.Key)*"){

        # Return the script
        return $script.Value
    }
}

return $null