<#
.NOTES
    *****************************************************************************
    ETML
    Name:	Add-UserGroups.ps1
    Author:	Sylvain Philipona
    Date:	12.05.2023
 	*****************************************************************************
    Modifications
 	Date  : 
 	Author: 
 	Reason: 
 	*****************************************************************************
.SYNOPSIS
    Add user to groups
 	
.DESCRIPTION
    Adds a user defined in arguments in a list of groups also defined in arguments
    Returns the list of groups with actions
  	
.PARAMETER User
    The user to add to the groups

.PARAMETER Groups
    The groups to add the user into

.OUTPUTS
	- An array containing all the groups to add to the user and the actions performed

.EXAMPLE
    "Sylvain Philipona" | .\Add-UserGroups.ps1 -Groups GUS_ETML_APPL_SELECTLINE_RO, GUS_ETML_INF_Eleves

    Group                       Action
    -----                       ------
    GUS_ETML_APPL_SELECTLINE_RO Success
    GUS_ETML_INF_Eleves         Success

.LINK
    https://www.reddit.com/r/PowerShell/comments/6k9foq/function_parameter_accept_username_string_or/
    https://lazyadmin.nl/powershell/get-aduser/
    https://stackoverflow.com/questions/24311293/powershell-system-array-to-csv-file
    https://morgantechspace.com/2015/07/powershell-check-if-ad-user-is-member-of-group.html

#>

##### Script parameters #####

param(
    [Parameter(Mandatory=$true, ValueFromPipeline = $true)]
    [ValidateNotNullOrEmpty()]
    $User,

    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string[]]$Groups
)

##### Script logic #####

# Retrieve the aduser
try{
    $AdUser = Get-ADUser -identity $User
}
catch{
    return $null
}

$returnData = @()

# Go through the whole array
foreach($group in $Groups){

    # Try to get the AdGroup object 
    try{

        # Get the AdGroup object
        $group | Get-ADGroup -ErrorAction Stop | Out-Null
    }
    catch{
        
        # Log that the group wasen't found in the domain
        $returnData += [pscustomobject]@{
            Group = $group
            Action = "Error"
        }
        continue
    }

    # Get all members of the group
    $members = (Get-ADGroupMember -Identity $group -Recursive | Select-Object -ExpandProperty Name)

    # Check if the user is member of the group
    if(!($members -and $members.Contains($AdUser.Name))){

        # Add the user to the group
        Add-ADGroupMember -Identity $group -Members $AdUser
    
        # Log the success action
        $returnData += [pscustomobject]@{
            Group = $group
            Action = "Success"
        }
    }
    else{

        # Log that no actions were perform
        $returnData += [pscustomobject]@{
            Group = $group
            Action = "Nothing"
        }
    }
}

# Return the groups and the actions performed
return $returnData