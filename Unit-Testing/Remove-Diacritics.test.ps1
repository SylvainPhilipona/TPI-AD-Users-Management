<#
.NOTES
    *****************************************************************************
    Name:	Remove-Diacritics.test.ps1
    Author:	Sylvain Philipona
    Date:	11.05.2023
 	*****************************************************************************
    Modifications
 	Date  : 31.05.2023
 	Author: Sylvain Philipona
 	Reason: Script moved to another directory
 	*****************************************************************************
.SYNOPSIS
    Unit tests for the Remove-Diacritics.test.ps1 script
 	
.DESCRIPTION
    A list of unit tests for the Remove-Diacritics.test.ps1 script
    A big range of inputs possibilities are tested
 	
.OUTPUTS
	The result of units tests

.EXAMPLE
    .\Scripts\Remove-Diacritics.test.ps1

    Starting discovery in 1 files.
    Discovery found 3 tests in 17ms.
    Running tests.
    [+] C:\Users\sylphilipona\GitHub\TPI-AD-Users-Management\Scripts\Remove-Diacritics.test.ps1 62ms (15ms|32ms)
    Tests completed in 65ms
    Tests Passed: 3, Failed: 0, Skipped: 0 NotRun: 0

.LINK
    https://pester.dev/docs/quick-start
    https://pester.dev/docs/v4/usage/assertions
#>

# Test multiple differents cases
Describe "Tests"{

    # L'été de Raphaël => LetedeRaphael
    It "L'été de Raphaël => LetedeRaphael"{
        (..\Scripts\Remove-Diacritics.ps1 -Text "L'été de Raphaël") | Should -Be "LetedeRaphael"
    }

    # ÚéõãÎÇĠ => UeoaICG
    It "ÚéõãÎÇĠ => UeoaICG"{
        (..\Scripts\Remove-Diacritics.ps1 -Text "ÚéõãÎÇĠ") | Should -Be "UeoaICG"
    }

    # Alessandro D'angélo => AlessandroDangelo
    It "Alessandro D'angélo => AlessandroDangelo"{
        (..\Scripts\Remove-Diacritics.ps1 -Text "Alessandro D'angélo") | Should -Be "AlessandroDangelo"
    }
}