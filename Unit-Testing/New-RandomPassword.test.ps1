<#
.NOTES
    *****************************************************************************
    Name:	New-RandomPassword.test.ps1
    Author:	Sylvain Philipona
    Date:	10.05.2023
 	*****************************************************************************
    Modifications
 	Date  : 31.05.2023
 	Author: Sylvain Philipona
 	Reason: Script moved to another directory
 	*****************************************************************************
.SYNOPSIS
    Unit tests for the New-RandomPassword.test.ps1 script
 	
.DESCRIPTION
    A list of unit tests for the New-RandomPassword.test.ps1 script
    A big range of inputs possibilities are tested
 	
.OUTPUTS
	The result of units tests

.EXAMPLE
    .\New-RandomPassword.test.ps1

    Starting discovery in 1 files.
    Discovery found 3 tests in 15ms.
    Running tests.
    [+] C:\Users\sylphilipona\GitHub\TPI-AD-Users-Management\Scripts\New-RandomPassword.test.ps1 63ms (26ms|24ms)
    Tests completed in 66ms
    Tests Passed: 3, Failed: 0, Skipped: 0 NotRun: 0

.LINK
    https://pester.dev/docs/quick-start
    https://pester.dev/docs/v4/usage/assertions
    https://learn.microsoft.com/en-us/dotnet/api/system.string.tochararray?view=net-7.0
#>


# Test multiple differents cases
Describe "Tests"{

    # New password with length of 16
    It "New password with length of 16"{
        (..\Scripts\New-RandomPassword.ps1 -Length 16).Length | Should -Be 16
    }

    # New password with default length
    It "New password with default length"{
        (..\Scripts\New-RandomPassword.ps1).Length | Should -Be 12
    }

    # New password without similar characters
    It "New password without similar characters"{
        $similar = "IlL10Oo"
        $password = (..\Scripts\New-RandomPassword.ps1 -Length 100 -ExcludeSimilar)
        
        # Check if the password contains a similar char
        $result = $true
        foreach($char in $similar.ToCharArray()){
            if($password.Contains($char)){
                $result = $false
            }
        }

        $result | Should -Be $true
    }
}