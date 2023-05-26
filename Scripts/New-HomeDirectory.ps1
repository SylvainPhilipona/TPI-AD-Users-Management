<#
.NOTES
    *****************************************************************************
    ETML
    Name:	New-HomeDirectory.ps1
    Author:	Sylvain Philipona
    Date:	15.05.2023
 	*****************************************************************************
    Modifications
 	Date  : 17.05.2023
 	Author: Sylvain Philipona
 	Reason: Access granted to users on theirs personals folders
 	*****************************************************************************
.SYNOPSIS
    Creates a home directory for the user
 	
.DESCRIPTION
    Creates a home directory for the user
    The main folder containing the home directories is created with the right access rights if it does not exist. 
    This folder shared on the network
  	
.PARAMETER Username
    The samAccountName of the user to create the home directory

.PARAMETER FolderPath
    The path of the main folder containing the home directories

.PARAMETER ShareName
    The name of the share that is or will be created on the network

.OUTPUTS
	- A main folder containing all users home folders
    - A share of this folder
    - A personal home folder accessible to the user
    - Return the path of the user home folder via a share

.EXAMPLE
    .\New-HomeDirectory.ps1 -Username "sylphilipon" -FolderPath "C:\USERHOMES" -ShareName "USERHOMES$"
    
    \\TPI-DC\USERHOMES$\sylphilipon

.LINK
    https://www.youtube.com/watch?v=BLdxbbnH9kU
    https://stackoverflow.com/questions/6573308/removing-all-acl-on-folder-with-powershell
    https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.security/get-acl?view=powershell-7.3
    
#>

##### Script parameters #####

param(
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$Username,

    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$FolderPath,

    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$ShareName
)

##### Script logic #####

# Check if the folder path is in the right format
if(!(Test-Path -LiteralPath $FolderPath -IsValid)){
    return $null
}

# Check if the user exists
if(!(Get-ADUser -Filter { SamAccountName -eq $Username })){
    return $null
}

# Create the userhomes main folder if not exists and manage the access rights
if(!(Test-Path -Path $FolderPath)){

    # Create the folder
    New-Item -ItemType Directory -Path $FolderPath -Force -Confirm:$false | Out-Null

    # Disable inheritance
    $acl = Get-ACL -Path $FolderPath
    $acl.SetAccessRuleProtection($True, $True)
    Set-Acl -Path $FolderPath -AclObject $acl

    # Remove all access to the folder
    $acl = Get-ACL -Path $FolderPath
    $acl.Access | ForEach-Object {
        $acl.RemoveAccessRule($_) | Out-Null
    }

    # Add full control access to the folder owner and the system
    $acl.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule($acl.Owner,"FullControl","Allow")))
    $acl.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule("SYSTEM","FullControl","Allow")))
    Set-Acl -Path $FolderPath -AclObject $acl
}

# Check if the main folder is shared
if(!(Get-SmbShare -Name $ShareName -ErrorAction SilentlyContinue)){

    # Share the folder
    New-SmbShare -Name $ShareName -Description "Dossiers Home des utilisateurs" -Path $FolderPath -Confirm:$false | Out-Null

    # Grant full access to everyone
    $everyone = ((Get-SmbShareAccess -Name $ShareName).AccountName)
    Grant-SmbShareAccess -Name $ShareName -AccountName $everyone -AccessRight Full -Force -Confirm:$false | Out-Null
}


# Check if the user folder exists
if(!(Test-Path "$FolderPath\$Username")){
    # Create the user folder
    New-Item -Path "$FolderPath\$Username" -ItemType Directory -Force -Confirm:$false | Out-Null
}

# Add the access to the user if the user exists
$acl = Get-ACL -Path "$FolderPath\$Username"
$acl.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule($Username,"FullControl","Allow")))
Set-Acl -Path "$FolderPath\$Username" -AclObject $acl

# Return the share path to the user home folder
return "\\$($env:COMPUTERNAME)\$ShareName\$Username"