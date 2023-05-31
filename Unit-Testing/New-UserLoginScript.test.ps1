<#
.NOTES
    *****************************************************************************
    Name:	New-UserLoginScript.test.ps1
    Author:	Sylvain Philipona
    Date:	12.05.2023
 	*****************************************************************************
    Modifications
 	Date  : 31.05.2023
 	Author: Sylvain Philipona
 	Reason: Script moved to another directory
 	*****************************************************************************
.SYNOPSIS
    Unit tests for the New-UserLoginScript.test.ps1 script
 	
.DESCRIPTION
    A list of unit tests for the New-UserLoginScript.test.ps1 script
    A big range of inputs possibilities are tested
 	
.OUTPUTS
	The result of units tests

.EXAMPLE
    .\Scripts\New-UserLoginScript.test.ps1

    

.LINK
    https://pester.dev/docs/quick-start
    https://pester.dev/docs/v4/usage/assertions
#>

# Test multiple differents cases
Describe "Tests"{

    # Ebeniste => BOIS.BAT
    It "Ebeniste => BOIS.BAT"{
        (..\Scripts\New-UserLoginScript.ps1 -Profession "Ebeniste") | Should -Be "BOIS.BAT"
    }

    # Informaticien => INF.BAT
    It "Informaticien => INF.BAT"{
        (..\Scripts\New-UserLoginScript.ps1 -Profession "Informaticien") | Should -Be "INF.BAT"
    }

    # menuisier => BOIS.BAT
    It "menuisier => BOIS.BAT"{
        (..\Scripts\New-UserLoginScript.ps1 -Profession "menuisier") | Should -Be "BOIS.BAT"
    }

    # Bucheron => null
    It "Bucheron => null"{
        (..\Scripts\New-UserLoginScript.ps1 -Profession "Bucheron") | Should -Be $null
    }
}