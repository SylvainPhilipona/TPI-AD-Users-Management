<#
.NOTES
    *****************************************************************************
    Name:	New-UserDescription.test.ps1
    Author:	Sylvain Philipona
    Date:	12.05.2023
 	*****************************************************************************
    Modifications
 	Date  : 31.05.2023
 	Author: Sylvain Philipona
 	Reason: Script moved to another directory
 	*****************************************************************************
.SYNOPSIS
    Unit tests for the New-UserDescription.test.ps1 script
 	
.DESCRIPTION
    A list of unit tests for the New-UserDescription.test.ps1 script
    A big range of inputs possibilities are tested
 	
.OUTPUTS
	The result of units tests

.EXAMPLE
    .\New-UserDescription.test.ps1

    Starting discovery in 1 files.
    Discovery found 3 tests in 10ms.
    Running tests.
    [+] C:\Users\sylphilipona\GitHub\TPI-AD-Users-Management\Scripts\New-UserDescription.test.ps1 54ms (14ms|33ms)
    Tests completed in 57ms
    Tests Passed: 3, Failed: 0, Skipped: 0 NotRun: 0

.LINK
    https://pester.dev/docs/quick-start
    https://pester.dev/docs/v4/usage/assertions
#>

# Test multiple differents cases
Describe "Tests"{

    # Cin2A => Cet utilisateur est membre de la classe Cin2A
    It "Cin2A => Cet utilisateur est membre de la classe Cin2A"{
        (..\Scripts\New-UserDescription.ps1 -Classe "Cin2A") | Should -Be "Cet utilisateur est membre de la classe Cin2A"
    }

    # CIN-CID3B => Cet utilisateur est membre de la classe CIN-CID3B
    It "CIN-CID3B => Cet utilisateur est membre de la classe CIN-CID3B"{
        (..\Scripts\New-UserDescription.ps1 -Classe "CIN-CID3B") | Should -Be "Cet utilisateur est membre de la classe CIN-CID3B"
    }

    # CPM2G => Cet utilisateur est membre de la classe CPM2G
    It "CPM2G => Cet utilisateur est membre de la classe CPM2G"{
        (..\Scripts\New-UserDescription.ps1 -Classe "CPM2G") | Should -Be "Cet utilisateur est membre de la classe CPM2G"
    }
}