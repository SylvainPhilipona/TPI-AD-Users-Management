<#
.NOTES
    *****************************************************************************
    ETML
    Name:	New-UserDescription.ps1
    Author:	Sylvain Philipona
    Date:	12.05.2023
 	*****************************************************************************
    Modifications
 	Date  : 
 	Author: 
 	Reason: 
 	*****************************************************************************
.SYNOPSIS
    Generating a description
 	
.DESCRIPTION
    Generating a description from the user classroom.

.PARAMETER Classe
    The classroom of the user

.OUTPUTS
	The generated description

.EXAMPLE
    .\New-UserDescription.ps1 -Classe "CIN-CID3B"

    Cet utilisateur est membre de la classe CIN-CID3B

#>

##### Script parameters #####

param(
    [Parameter(Mandatory=$true)]
    [string]$Classe
)

##### Constants #####

$KEYWORD = "[classe]"

##### Variables #####

$description = "Cet utilisateur est membre de la classe $KEYWORD"

##### Script logic #####

return $description.Replace($KEYWORD, $Classe)