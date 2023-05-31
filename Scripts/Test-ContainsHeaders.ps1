<#
.NOTES
    *****************************************************************************
    ETML
    Name:	Test-ContainsHeaders.ps1
    Author:	Sylvain Philipona
    Date:	17.05.2023
 	*****************************************************************************
    Modifications
 	Date  : 
 	Author: 
 	Reason: 
 	*****************************************************************************
.SYNOPSIS
    Checking for existence of required headers in a CSV file
 	
.DESCRIPTION
    This PowerShell script checks if a set of required CSV headers are present in a CSV file
  	
.PARAMETER CsvHeaders
    Represents the CSV headers of the file

.PARAMETER Headers
    specifies the required headers

.OUTPUTS
    - Returns True or False depending on whether all required headers are int the csv or not

.EXAMPLE
    .\Test-ContainsHeaders.ps1 -CsvHeaders $csvHeaders -Headers $requiredHeaders

    True
#>


param (
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    $CsvHeaders,

    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    $Headers
)

# Go trough all required headers
foreach($Header in $Headers){

    # Check if the CSV headers contains the required header
    if(!$CsvHeaders.Contains($Header)){

        # If the CSV headers does not contains the required header
        return $false
    }
}

return $true