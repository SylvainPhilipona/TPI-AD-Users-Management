<#
.NOTES
    *****************************************************************************
    Name:	New-UserLogin.test.ps1
    Author:	Sylvain Philipona
    Date:	10.05.2023
 	*****************************************************************************
    Modifications
 	Date  : 
 	Author: 
 	Reason: 
 	*****************************************************************************
.SYNOPSIS
    Unit tests for the New-UserLogin.ps1 script
 	
.DESCRIPTION
    A list of unit tests for the New-UserLogin.ps1 script
    A big range of inputs possibilities are tested
 	
.OUTPUTS
	The result of units tests

.EXAMPLE
    .\New-UserLogin.test.ps1

    Starting discovery in 1 files.
    Discovery found 7 tests in 12ms.
    Running tests.
    [+] C:\Users\sylphilipona\GitHub\TPI-AD-Users-Management\Scripts\New-UserLogin.test.ps1 70ms (25ms|35ms)
    Tests completed in 73ms
    Tests Passed: 7, Failed: 0, Skipped: 0 NotRun: 0

.LINK
    https://pester.dev/docs/quick-start
    https://pester.dev/docs/v4/usage/assertions
#>


# Test multiple differents cases
Describe "Tests"{
    # Sylvain Philipona => sylphilipon
    It "Sylvain Philipona => sylphilipon"{
        (.\New-UserLogin.ps1 -FirstName "Sylvain" -LastName "Philipona") | Should -Be "sylphilipon"
    }

    # John Doe => johdoe
    It "John Doe => johdoe"{
        (.\New-UserLogin.ps1 -FirstName "John" -LastName "Doe") | Should -Be "johdoe"
    }

    # JOHN DOE => johdoe
    It "JOHN DOE => johdoe"{
        (.\New-UserLogin.ps1 -LastName "DOE"  -FirstName "JOHN") | Should -Be "johdoe"
    }

    # Alessandro D'angélo => aled'angélo
    It "Alessandro D'angélo => aled'angélo"{
        (.\New-UserLogin.ps1 -FirstName "Alessandro" -LastName "D'angélo") | Should -Be "aled'angélo"
    }

    # Jo Chen => jochen
    It "Jo Chen => jochen"{
        (.\New-UserLogin.ps1 -FirstName "Jo" -LastName "Chen") | Should -Be "jochen"
    }

    # Fernandez Charpentier => fercharpent
    It "Fernandez Charpentier => fercharpent"{
        (.\New-UserLogin.ps1 -FirstName "Fernandez" -LastName "Charpentier") | Should -Be "fercharpent"
    }

    # No arguments => empty string
    It "No arguments => empty string"{
        (.\New-UserLogin.ps1) | Should -Be ""
    }
}