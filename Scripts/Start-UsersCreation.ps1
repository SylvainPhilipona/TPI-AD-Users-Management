<#
.NOTES
    *****************************************************************************
    ETML
    Name:	Start-UsersCreation.ps1
    Author:	Sylvain Philipona
    Date:	17.05.2023
 	*****************************************************************************
    Modifications
 	Date  : 31.05.2023
 	Author: Sylvain Philipona
 	Reason: Adding Email handling
 	*****************************************************************************
.SYNOPSIS
    Create AD users based on data provided in a CSV
 	
.DESCRIPTION
    Imports a CSV file containing user data.
    Checks required headers, generate unique usernames and create the users in the Active Directory.
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

    User creation : Joca TestNull.
    User creation : Sylvain Philipona.
    User creation : Sylvain Philipone.
    User creation : Sylvain Philiponu.
    User creation : Joca Bolli.
    User creation : Nolan Praz.
    User creation : Alessandro D'angélo.
    User creation : Mihăescu Negoiță.
    User creation : Mihăesco PGNJZQO.

    User                Action  Login        Password     LoginScript HomeDirectory                    Comments
    ----                ------  -----        --------     ----------- -------------                    --------
    Joca TestNull       Failed                                                                         The user 'Joca...
    Sylvain Philipona   Success sylphilipon  F9cay5#RWkYJ INF.BAT     \\TPI-DC\USERHOMES$\sylphilipon  The account 's...
    Sylvain Philipone   Success sylphilipon1 SqfTwzj9a8u& INF.BAT     \\TPI-DC\USERHOMES$\sylphilipon1 The account 's...
    Sylvain Philiponu   Success sylphilipon2 tQ&dy*GPU#qa INF.BAT     \\TPI-DC\USERHOMES$\sylphilipon2 The account 's...
    Joca Bolli          Success jocbolli     S-ddmge3xrqW AM.BAT      \\TPI-DC\USERHOMES$\jocbolli     The account 'j...
    Nolan Praz          Success nolpraz      Tzu*YS78RBk4 BOIS.BAT    \\TPI-DC\USERHOMES$\nolpraz      The account 'n...
    Alessandro D'angélo Success aledangelo   FgjD7S#p2-Hi ELO.BAT     \\TPI-DC\USERHOMES$\aledangelo   The account 'a...
    Mihăescu Negoiță    Success mihnegoita   Uv-@vZa3yMrp INF.BAT     \\TPI-DC\USERHOMES$\mihnegoita   The account 'm...
    Mihăesco PGNJZQO    Success mihpgnjzqo   bW2RTj*eHyHy INF.BAT     \\TPI-DC\USERHOMES$\mihpgnjzqo   The account 'm...



    The actions are logged in the file 'Z:\CSV\04-createdUsers.csv'.

.LINK
    https://stackoverflow.com/questions/28787364/check-file-extension
    https://learn.microsoft.com/en-us/powershell/module/activedirectory/new-aduser?view=windowsserver2022-ps
    https://stackoverflow.com/questions/35141099/changepasswordatlogon-not-applying-on-new-aduser-when-enabled-is-false
    https://stackoverflow.com/questions/36585500/how-to-display-formatted-output-with-write-host
    
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
$GROUPS_SPLIT_CHAR = "%"
$HOME_DRIVE_LETTER = "H:"
$HOME_DRIVE_PATH = "C:\USERHOMES"
$HOME_DRIVE_SHARE = "USERHOMES$"
$PASSWORD_LENGTH = 12
$PASSWORD_SPECIALS_CHARS = "!#$&*-/=?@_"
$DEFAULT_ACTIONS_FILE = "Actions.csv"

##### Variables #####

$tagPrenom = "Prenom"
$tagNom = "Nom"
$tagEmail = "E-mail"
$tagClasse = "Classe"
$tagProfession = "Profession"
$tagGroups = "OptionsAD"
$requiredHeaders = @($tagPrenom, $tagNom, $tagEmail, $tagClasse, $tagProfession, $tagGroups)

##### Script logic #####

# Check if the active directory module is installed
if(!(Get-Module -ListAvailable -name ActiveDirectory)){
    Write-Host "The ActiveDirectory module isn't installed. Please install it and retry." -ForegroundColor Red
    exit
}

# Check if the file exists and is in the .csv format
if(!(Test-Path -Path $UsersCSV -PathType Leaf) -or [IO.Path]::GetExtension($UsersCSV).ToLower() -ne ".csv"){
    Write-Host "The file '$UsersCSV' does not exist or is not in CSV format." -ForegroundColor Red
    exit
}

# Import the csv file and retrieve the csv headers
$users = Import-Csv $UsersCSV -Encoding UTF8 -Delimiter $CSVDelimiter
$csvHeaders = ($users | Get-Member -MemberType NoteProperty).Name

# Check if the csv contains all required headers
if(!(.\Test-ContainsHeaders.ps1 -CsvHeaders $csvHeaders -Headers $requiredHeaders)){
    Write-Host "The file '$UsersCSV' does not contain the required fields : $($requiredHeaders -Join(', '))." -ForegroundColor Red
    exit
}

# Check if the csv file has the right delimiter
if($csvHeaders.Split($CSVDelimiter).Length -le 1){
    Write-Host "The file '$UsersCSV' is not delimited by the character '$CSVDelimiter'." -ForegroundColor Red
    exit
}

# Csv with all actions performed
$allActions = @()

# Create all accounts
foreach($user in $users){

    # Display the user creation message
    Write-Host "User creation : $($user.$tagPrenom) $($user.$tagNom)." -ForegroundColor Green

    # Define the user actions data
    # This data will be completed according to the script actions performed
    $userActions = @{
        User = "$($user.$tagPrenom) $($user.$tagNom)"
        Action = $null
        Login = $null
        Email = $null
        Password = $null
        LoginScript = $null
        HomeDirectory = $null
        Comments = $null
        Groups = $null
    }

    # Get if one of the required fields is empty
    $emptyField = $false
    foreach($tag in $requiredHeaders){

        # Check if the field is empty
        if(!($user.$tag)){

            # One field is empty
            $emptyField = $true
            break
        }
    }

    # If one field is empty
    if($emptyField){

        # One field is empty
        $userActions["Action"] = "Failed"
        $userActions["Comments"] = "The user '$($user.$tagPrenom) $($user.$tagNom)' has empty fields."
        $allActions += [PSCustomObject]$userActions
        continue
    }

    # Check if the user already exists
    if(.\Find-User.ps1 -FirstName $user.$tagPrenom -LastName $user.$tagNom){

        # The user already exists
        $userActions["Action"] = "Failed"
        $userActions["Comments"] = "The user '$($user.$tagPrenom) $($user.$tagNom)' already exists."
        $allActions += [PSCustomObject]$userActions
        continue
    }

    # Generate login name without diacritics
    $firstNameNoDiacr = .\Remove-Diacritics.ps1 -Text $user.$tagPrenom
    $lastNameNoDiacr = .\Remove-Diacritics.ps1 -Text $user.$tagNom
    $samAccountName = .\New-UserLogin.ps1 -FirstName $firstNameNoDiacr -LastName $lastNameNoDiacr

    # Check if the login name already exists
    # Regenerate the login name with a number at the end of it, while the genereted name already exists
    $i = 1
    while (.\Find-UserLogin.ps1 -Login $samAccountName) {
        $samAccountName = "$(.\New-UserLogin.ps1 -FirstName $firstNameNoDiacr -LastName $lastNameNoDiacr)$i"
        $i++
    }

    # Generate the password forcing specials chars
    $password = .\New-RandomPassword.ps1 -Length $PASSWORD_LENGTH -ExcludeSimilar
    while($password -notmatch "[$($PASSWORD_SPECIALS_CHARS)]"){
        $password = .\New-RandomPassword.ps1 -Length $PASSWORD_LENGTH -ExcludeSimilar
    }

    # Generate the description and login script
    $description = .\New-UserDescription.ps1 -Classe $user.$tagClasse
    $logonScript = .\New-UserLoginScript.ps1 -Profession $user.$tagProfession

    # Set the proprieties of the new user
    $newUserProps = @{
        displayName             = "$($user.$tagPrenom) $($user.$tagNom)"
        name                    = "$($user.$tagPrenom) $($user.$tagNom)"
        GivenName               = $user.$tagPrenom
        Surname                 = $user.$tagNom
        samAccountName          = $samAccountName
        userPrincipalName       = $user.$tagEmail
        EmailAddress            = $user.$tagEmail
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
    # Split the group field from the csv and add the groups prefix at the start of it
    # Return a hashtable of actions performed
    $groups = $user.$tagGroups.Split($GROUPS_SPLIT_CHAR) | ForEach-Object {
        $_.Replace($_, "$($GROUPS_PREFIX)$($_)")
    }
    $groupsActions = $samAccountName | .\Add-UserGroups.ps1 -Groups $groups | ForEach-Object{
        "$($_.Group) => $($_.Action)"
    }
    
    # Log the actions performed on the user
    $userActions["Action"] = "Success"
    $userActions["Login"] = $samAccountName
    $userActions["Email"] = $user.$tagEmail
    $userActions["Password"] = $password
    $userActions["LoginScript"] = $logonScript
    $userActions["HomeDirectory"] = $homeDir
    $userActions["Comments"] = "The account '$samAccountName' was successfully created."
    $userActions["Groups"] = ($groupsActions -join $CSVDelimiter)
    $allActions += [PSCustomObject]$userActions
}

# Format the logged actions for better lisibility
$allActions = $allActions | Select-Object User, Action, Login, Email, Password, LoginScript, HomeDirectory, Comments, Groups

# Check if the path is valid and the file extension is .csv
if(!(Test-Path $ActionsCSV -IsValid) -or [IO.Path]::GetExtension($ActionsCSV).ToLower() -ne ".csv"){
    Write-Host "The file path '$ActionsCSV' is not a valid path or is not in the .csv extension." -ForegroundColor Red
    $ActionsCSV = "$(Get-Location)\$DEFAULT_ACTIONS_FILE"
}

# Export and the actions in a .csv
$allActions | Export-Csv -Path $ActionsCSV -NoTypeInformation -Encoding UTF8 -Delimiter $CSVDelimiter -Force
Write-Host ($allActions | Format-Table | Out-String)
Write-Host "The actions are logged in the file '$ActionsCSV'." -ForegroundColor Yellow