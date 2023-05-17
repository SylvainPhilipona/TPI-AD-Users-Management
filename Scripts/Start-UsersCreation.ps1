# https://stackoverflow.com/questions/28787364/check-file-extension
# https://learn.microsoft.com/en-us/powershell/module/activedirectory/new-aduser?view=windowsserver2022-ps

param(
    # [string]$UsersCSV = "C:\Users\sylphilipona\GitHub\TPI-AD-Users-Management\Administratif\creationUsers-XXX.csv",
    [string]$UsersCSV = "Z:\Administratif\creationUsers-XXX.csv",
    [char]$CSVDelimiter = ";"
    # [string]$UsersCSV = "C:\Users\sylphilipona\GitHub\TPI-AD-Users-Management\Administratif\sylphilipona-RapportTPI.docx"
    # [string]$UsersCSV = "C:\Users\sylphilipona\GitHub\TPI-AD-Users-Management\Administratif\TPI-RFA-SylvainPhilipona-CdC-V2.3.pdf.csv"
)

# Requirieds CSV headers
$requiredHeaders = @(
    "Prenom",
    "Nom",
    "Classe",
    "Profession",
    "OptionsAD"
)

# Check if the file exists and is in the .csv format
if(!(Test-Path -Path $UsersCSV -PathType Leaf) -or [IO.Path]::GetExtension($UsersCSV).ToLower() -ne ".csv"){
    Write-Host "Le fichier n'existe pas ou n'est pas dans le format CSV" -ForegroundColor Red
    exit
}

# Import the csv file ang retrieve the csv headers
$users = Import-Csv $UsersCSV -Encoding UTF8 -Delimiter $CSVDelimiter
$csvHeaders = ($users | Get-Member -MemberType NoteProperty).Name

# Check if the csv contains all required headers
if(!(.\Test-ContainsHeaders.ps1 -CsvHeaders $csvHeaders -Headers $requiredHeaders)){
    Write-Host "Le fichier '$UsersCSV' ne contient pas tous les champs requis : $($requiredHeaders -Join(', '))" -ForegroundColor Red
    exit
}


# Create all accounts
foreach($user in $users){

    # Check if the user already exists
    if(.\Find-User.ps1 -FirstName $user.Prenom -LastName $user.Nom){
        Write-Host "L'utilisateur $($user.Prenom) $($user.Nom) existe déjà." -ForegroundColor Cyan
        continue
    }

    Write-Host "Création de l'utilisateur $($user.Prenom) $($user.Nom)" -ForegroundColor Green

    # Generate login name without diacritics
    $samAccountName = .\New-UserLogin.ps1 -FirstName (.\Remove-Diacritics.ps1 -Text $user.Prenom) -LastName (.\Remove-Diacritics.ps1 -Text $user.Nom)
    Write-Host "Generate login name without diacritics" -ForegroundColor Yellow
    
    # Check if the login name already exists
    if(.\Find-UserLogin.ps1 -Login $samAccountName){

        ###################################
        ##### Regenerate a login name #####
        ###################################

    }

    # Generate the password
    $password = .\New-RandomPassword.ps1 -Length 12 -ExcludeSimilar
    $password = "NininoLeFilm1234"
    Write-Host "Generate the password" -ForegroundColor Yellow

    # Generate the description
    $description = .\New-UserDescription.ps1 -Classe $user.Classe
    Write-Host "Generate the description" -ForegroundColor Yellow

    # Create the login script
    $logonScript = .\New-UserLoginScript.ps1 -Profession $user.Profession
    Write-Host "Create the login script" -ForegroundColor Yellow

    # Create and enable the user
    $newUserProps = @{
        displayName             = "$($user.Prenom) $($user.Nom)"
        name                    = "$($user.Prenom) $($user.Nom)"
        GivenName               = $user.Prenom
        Surname                 = $user.Nom
        samAccountName          = $samAccountName
        AccountPassword         = ConvertTo-SecureString $password -AsPlainText -Force
        ChangePasswordAtLogon   = $True 
        Description             = $description
        Path                    = "OU=students,DC=tpi,DC=local"

        # profilePath             = $logonScript
        Office                  = $password
    }
    New-ADUser @newUserProps
    Enable-ADAccount -Identity $samAccountName 
    Write-Host "Create and enable the user" -ForegroundColor Yellow

    # Create and map the home directory of the user
    $homeDir = .\New-HomeDirectory.ps1 -Username $samAccountName -FolderPath "C:\USERHOMES" -ShareName "USERHOMES$"
    Set-ADUser -Identity $samAccountName -homeDirectory $homeDir -homeDrive "H:"
    Write-Host "Create and map the home directory of the user" -ForegroundColor Yellow

    # Add the user to the groups
    $groups = $user.OptionsAD.Split("%") | ForEach-Object {
        $_.Replace($_, "GUS_ETML_$_")
    }
    $result = $samAccountName | .\Add-UserGroups.ps1 -Groups $groups
    Write-Host "Add the user to the groups" -ForegroundColor Yellow
}