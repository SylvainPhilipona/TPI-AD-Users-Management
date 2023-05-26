<#
.NOTES
    *****************************************************************************
    ETML
    Name:	Start-UsersModification.ps1
    Author:	Sylvain Philipona
    Date:	26.05.2023
 	*****************************************************************************
    Modifications
 	Date  : 
 	Author: 
 	Reason: 
 	*****************************************************************************
.SYNOPSIS
    Edit AD users based on data provided in a CSV
 	
.DESCRIPTION
    Imports a CSV file containing user data.
    Checks required headers, and check if the users has to be deleted or desactivate.
    Edit the users.
    All actions are performed are recorded in another CSV file.
  	
.PARAMETER UsersCSV
    The CSV file containing all users to edit with theirs data

.PARAMETER ActionsCSV
    The CSV file that will be created / overwritted with the new created users 

.PARAMETER CSVDelimiter
    The delimiter of the CSV file

.OUTPUTS
    - A csv file logging all actions performed

.EXAMPLE
    .\Start-UsersModification.ps1 -UsersCSV "Z:\CSV\02-modificationUsers.csv" -ActionsCSV "Z:\CSV\05-editedUsers.csv"

#>

##### Script parameters #####

param(
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$UsersCSV,

    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$ActionsCSV,

    [ValidateNotNullOrEmpty()]
    [char]$CSVDelimiter = ";"
)

##### Constants #####

$DEFAULT_ACTIONS_FILE = "Actions.csv"

##### Variables #####

$tagLogin = "Login"
$tagClasse = "Classe"
$tagGroups = "OptionsAD"
$tagProfession = "Profession"
$requiredHeaders = @($tagLogin, $tagGroups, $tagClasse, $tagProfession)

##### Script logic #####

# Check if the active directory module is installed
if(!(Get-Module -ListAvailable -name ActiveDirectory)){
    Write-Host "The ActiveDirectory module isn't installed. Please install it and retry." -ForegroundColor Red
    exit
}

# Check if the file exists and is in the .csv format
if(!(Test-Path -Path $UsersCSV -PathType Leaf) -or [IO.Path]::GetExtension($UsersCSV).ToLower() -ne ".csv"){
    Write-Host "The file does not exist or is not in CSV format." -ForegroundColor Red
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

# Edit all users
foreach($user in $users){

    # Display the user deletion message
    $userLogin = $user.$tagLogin
    Write-Host "User modification : $userLogin." -ForegroundColor Green

    # Define the user actions data
    # This data will be completed according to the script actions performed
    $userActions = @{
        User = $userLogin
        Action = $null
        Classe = $null
        LoginScript = $null
        Comments = $null
        Groups = $null
    }

    # Check if the user login field isn'e null or empty
    if(!$userLogin){
        $userActions["Action"] = "Failed"
        $userActions["Comments"] = "The '$tagLogin' field is empty."
        $allActions += [PSCustomObject]$userActions
        continue
    }

    # Check if the user exists
    $adUser = Get-ADUser -Filter {samAccountName -eq $userLogin}
    if(!($adUser)){

        # The user already exists
        $userActions["Action"] = "Failed"
        $userActions["Comments"] = "The user '$userLogin' doesn't exists."
        $allActions += [PSCustomObject]$userActions
        continue
    }




    









    # Log the actions performed on the user
    $allActions += [PSCustomObject]$userActions
}




# Format the logged actions for better lisibility
$allActions = $allActions | Select-Object User, Action, Classe, LoginScript, Comments, Groups

# Check if the path is valid and the file extension is .csv
if(!(Test-Path $ActionsCSV -IsValid) -or [IO.Path]::GetExtension($ActionsCSV).ToLower() -ne ".csv"){
    Write-Host "The file path '$ActionsCSV' is not a valid path or is not in the .csv extension." -ForegroundColor Red
    $ActionsCSV = "$(Get-Location)\$DEFAULT_ACTIONS_FILE"
}

# Export and the actions in a .csv
$allActions | Export-Csv -Path $ActionsCSV -NoTypeInformation -Encoding UTF8 -Delimiter $CSVDelimiter -Force
Write-Host ($allActions | Format-Table | Out-String)
Write-Host "The actions are logged in the file '$ActionsCSV'." -ForegroundColor Yellow









