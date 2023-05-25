<#
.NOTES
    *****************************************************************************
    ETML
    Name:	Start-UsersCreation.ps1
    Author:	Sylvain Philipona
    Date:	17.05.2023
 	*****************************************************************************
    Modifications
 	Date  : 22.05.2023
 	Author: Sylvain Philipona
 	Reason: CSV export of all actions performed
 	*****************************************************************************
.SYNOPSIS
    Create AD users based on data provided in a CSV
 	
.DESCRIPTION
    Imports a CSV file containing user data.
    Checks required headers, generate unique usernames and creat the users in the Active Directory.
    It configure users properties such as password and login script, create home directories and add users to specified groups.
    All actions are performed are recorded in another CSV file.
  	
.PARAMETER UsersCSV
    The CSV file containing all users to create with theirs data

.PARAMETER ActionsCSV
    The CSV file that will be created / overwritted with the new created users 

.PARAMETER CSVDelimiter
    The delimiter of the CSV file

.PARAMETER OUPath
    The path of the Organizational Unit where the users will be created

.OUTPUTS
	- All created AD Users
    - A csv file logging all actions performed

.EXAMPLE
    .\Start-UsersCreation.ps1 -UsersCSV "Z:\Administratif\creationUsers-XXX.csv" -ActionsCSV "Z:\Administratif\UsersCreation.csv" -OUPath "OU=students,DC=tpi,DC=local" -CSVDelimiter ";"

    User creation Sylvain Philipona
    User creation Joca Bolli
    User creation Nolan Praz
    User creation Alessandro D'angélo
    User creation Mihăesco Negoiță
    The actions are logged in the file 'Z:\Administratif\UsersCreation.csv'

.LINK
    https://stackoverflow.com/questions/28787364/check-file-extension
    https://learn.microsoft.com/en-us/powershell/module/activedirectory/new-aduser?view=windowsserver2022-ps
    https://stackoverflow.com/questions/35141099/changepasswordatlogon-not-applying-on-new-aduser-when-enabled-is-false
    
#>

##### Script parameters #####

param(
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$UsersCSV,

    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$ActionsCSV,

    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$OUPath,

    [ValidateNotNullOrEmpty()]
    [char]$CSVDelimiter = ";"
)

##### Constants #####

$GROUPS_PREFIX = "GUS_ETML_"
$HOME_DRIVE_LETTER = "H:"
$HOME_DRIVE_PATH = "C:\USERHOMES"
$HOME_DRIVE_SHARE = "USERHOMES$"

##### Variables #####

$requiredHeaders = @(
    "Prenom",
    "Nom",
    "Classe",
    "Profession",
    "OptionsAD"
)

##### Script logic #####

# Check if the file exists and is in the .csv format
if(!(Test-Path -Path $UsersCSV -PathType Leaf) -or [IO.Path]::GetExtension($UsersCSV).ToLower() -ne ".csv"){
    Write-Host "The file does not exist or is not in CSV format" -ForegroundColor Red
    exit
}

# Import the csv file and retrieve the csv headers
$users = Import-Csv $UsersCSV -Encoding UTF8 -Delimiter $CSVDelimiter
$csvHeaders = ($users | Get-Member -MemberType NoteProperty).Name

# Check if the csv contains all required headers
if(!(.\Test-ContainsHeaders.ps1 -CsvHeaders $csvHeaders -Headers $requiredHeaders)){
    Write-Host "The file '$UsersCSV' does not contain all required fields : $($requiredHeaders -Join(', '))" -ForegroundColor Red
    exit
}

# Check if the csv file has the right delimiter
if($csvHeaders.Split($CSVDelimiter).Length -le 1){
    Write-Host "The file '$UsersCSV' is not delimited by the character '$CSVDelimiter'" -ForegroundColor Red
    exit
}

# Csv with all actions performed
$allActions = @()

# Create all accounts
foreach($user in $users){

    Write-Host "User creation $($user.Prenom) $($user.Nom)" -ForegroundColor Green

    # Define the user actions data
    # This data will be completed according to the script actions performed
    $userActions = @{
        User = "$($user.Prenom) $($user.Nom)"
        Action = $null
        Login = $null
        Password = $null
        LoginScript = $null
        HomeDirectory = $null
        Comments = $null
        Groups = $null
    }

    # Check if the user already exists
    if(.\Find-User.ps1 -FirstName $user.Prenom -LastName $user.Nom){

        # The user already exists
        $userActions["Action"] = "Failed"
        $userActions["Comments"] = "The user '$($user.Prenom) $($user.Nom)' already exists."
        $allActions += [PSCustomObject]$userActions
        continue
    }

    # Generate login name without diacritics
    $firstNameNoDiacr = .\Remove-Diacritics.ps1 -Text $user.Prenom
    $lastNameNoDiacr = .\Remove-Diacritics.ps1 -Text $user.Nom
    $samAccountName = .\New-UserLogin.ps1 -FirstName $firstNameNoDiacr -LastName $lastNameNoDiacr
    
    # Check if the login name already exists
    # Regenerate the login name with a number at the end of it, while the genereted name already exists
    $i = 1
    while (.\Find-UserLogin.ps1 -Login $samAccountName) {
        $samAccountName = "$(.\New-UserLogin.ps1 -FirstName $firstNameNoDiacr -LastName $lastNameNoDiacr)$i"
        $i++
    }

    # Generate the password, description and login script
    $password = .\New-RandomPassword.ps1 -Length 12 -ExcludeSimilar
    $description = .\New-UserDescription.ps1 -Classe $user.Classe
    $logonScript = .\New-UserLoginScript.ps1 -Profession $user.Profession

    # Set the proprieties of the new user
    $newUserProps = @{
        displayName             = "$($user.Prenom) $($user.Nom)"
        name                    = "$($user.Prenom) $($user.Nom)"
        GivenName               = $user.Prenom
        Surname                 = $user.Nom
        samAccountName          = $samAccountName
        AccountPassword         = ConvertTo-SecureString $password -AsPlainText -Force
        Description             = $description
        Path                    = $OUPath
        scriptPath              = $logonScript
    }

    try{

        # Create and enable the user
        New-ADUser @newUserProps
        Set-ADUser -Identity $samAccountName -ChangePasswordAtLogon $true
        Enable-ADAccount -Identity $samAccountName
    }
    catch{

        # An error occured during the account creation process
        $userActions["Action"] = "Failed"
        $userActions["Login"] = $samAccountName
        $userActions["password"] = $password
        $userActions["Comments"] = $_
        $allActions += [PSCustomObject]$userActions
        continue
    }

    # Create and map the home directory of the user
    $homeDir = .\New-HomeDirectory.ps1 -Username $samAccountName -FolderPath $HOME_DRIVE_PATH -ShareName $HOME_DRIVE_SHARE
    Set-ADUser -Identity $samAccountName -homeDirectory $homeDir -homeDrive $HOME_DRIVE_LETTER

    # Add the user to the groups
    # Split the group field from the csv and add the groups suffix at the start of it
    # Return a hashtable of actions performed
    $groups = $user.OptionsAD.Split("%") | ForEach-Object {
        $_.Replace($_, "$($GROUPS_PREFIX)$($_)")
    }
    $groupsActions = $samAccountName | .\Add-UserGroups.ps1 -Groups $groups | ForEach-Object{
        "$($_.Group) => $($_.Action)"
    }
    
    $userActions["Action"] = "Success"
    $userActions["Login"] = $samAccountName
    $userActions["Password"] = $password
    $userActions["LoginScript"] = $logonScript
    $userActions["HomeDirectory"] = $homeDir
    $userActions["Comments"] = "The account '$samAccountName' was successfully created"
    $userActions["Groups"] = ($groupsActions -join $CSVDelimiter)
    $allActions += [PSCustomObject]$userActions
}

# Check if the path is valid and the file extension is .csv
if(!(Test-Path $ActionsCSV -IsValid) -or [IO.Path]::GetExtension($ActionsCSV).ToLower() -ne ".csv"){
    Write-Host "The file path '$ActionsCSV' is not a valid path or not in the .csv extension" -ForegroundColor Red
    $ActionsCSV = "$(Get-Location)\Actions.csv"
}

# Export the actions in a .csv
$allActions | Export-Csv -Path $ActionsCSV -NoTypeInformation -Encoding UTF8 -Delimiter $CSVDelimiter -Force
Write-Host "The actions are logged in the file '$ActionsCSV'" -ForegroundColor Yellow