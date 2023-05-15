<#
.NOTES
    *****************************************************************************
    ETML
    Name:	New-HomeDirectory.ps1
    Author:	Sylvain Philipona
    Date:	15.05.2023
 	*****************************************************************************
    Modifications
 	Date  : 
 	Author: 
 	Reason: 
 	*****************************************************************************
.SYNOPSIS
    
 	
.DESCRIPTION
    
  	
.PARAMETER 
    

.PARAMETER 
    

.OUTPUTS
	- 

.EXAMPLE
    .\

.LINK
    https://stackoverflow.com/questions/6573308/removing-all-acl-on-folder-with-powershell
    https://www.youtube.com/watch?v=BLdxbbnH9kU
    
#>



param(
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$Username = "sylphilipona",

    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$FolderPath = "C:\USERS_HOMES",

    [ValidateNotNullOrEmpty()]
    [string]$ShareName = "TEST$"
)



# Create the userhomes main folder if not exists and manage the access rights
if(!(Test-Path -Path $FolderPath)){

    # Create the folder
    New-Item -ItemType Directory -Path $FolderPath -Force -Confirm:$false

    # Remove all access to the folder
    $acl = Get-ACL -Path $FolderPath
    $acl.Access | ForEach-Object {
        $acl.RemoveAccessRule($_)
    }

    # Add full control access to the folder owner and the system
    $acl.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule($acl.Owner,"FullControl","Allow")))
    $acl.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule("SYSTEM","FullControl","Allow")))

    # Disable inheritance
    $acl.SetAccessRuleProtection($True, $True)
    Set-Acl -Path $FolderPath -AclObject $acl
}


if(!(Get-SmbShare -Name $ShareName -ErrorAction SilentlyContinue)){

    # Share the folder
    New-SmbShare -Name $ShareName -Description "Dossiers Home des utilisateurs" -Path $FolderPath -Confirm:$false

    # Grant full access to everyone
    $everyone = ((Get-SmbShareAccess -Name $ShareName).AccountName)
    Grant-SmbShareAccess -Name $ShareName -AccountName $everyone -AccessRight Full -Force -Confirm:$false

}