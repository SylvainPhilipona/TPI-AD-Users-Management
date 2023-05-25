<#
.NOTES
    *****************************************************************************
    ETML
    Name:	Remove-Diacritics.ps1
    Author:	Sylvain Philipona
    Date:	11.05.2023
 	*****************************************************************************
    Modifications
 	Date  : 
 	Author: 
 	Reason: 
 	*****************************************************************************
.SYNOPSIS
    Remove the diacritics in a string
 	
.DESCRIPTION
    Remove all the diacritics, spaces and punctuation marks in a string
    This use the Unicode normalization

.PARAMETER Text
    The input string that will have diacritics removed

.OUTPUTS
	- The string with diacritics removed

.EXAMPLE
    .\Remove-Diacritics.ps1 -Text "L'été de Raphaël"
    
    LetedeRaphael

.LINK
    https://lazywinadmin.com/2015/05/powershell-remove-diacritics-accents.html
    https://learn.microsoft.com/fr-fr/dotnet/api/system.string.normalize?view=net-8.0
    https://unicode.org/reports/tr15/
    https://learn.microsoft.com/en-us/dotnet/api/system.globalization.unicodecategory?view=net-8.0
#>

##### Script parameters #####

param(
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$Text
)

##### Variables #####

$normalizedText = ""

##### Script logic #####

# Remove the spaces and punctuation marks
$Text = $Text.Replace("'", "")
$Text = $Text.Replace(" ", "")

# Split characters composed of several characters (é => e ´)
# Example : L'été de Raphaël => L ' e ́ t e ́   d e   R a p h a e ̈ l
[System.Text.NormalizationForm]$normalizationForm = "FormD"

# Normalize the text
$Normalized = $Text.Normalize($normalizationForm)

# Iterates through all text in the format of a character array
foreach($char in $normalized.ToCharArray()){

    # Nonspacing character that indicates modifications of a base character
    # Check if the character isn't nonspacing
    if ([Globalization.CharUnicodeInfo]::GetUnicodeCategory($char) -ne [Globalization.UnicodeCategory]::NonSpacingMark)
    {
        # Add the nonspacing character to the result string
        $normalizedText += $char
    }
}

# Return the string without diacritics, spaces and punctuation marks
return $normalizedText