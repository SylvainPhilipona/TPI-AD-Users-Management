<#
.NOTES
    *****************************************************************************
    ETML
    Name:	Start-UsersDeletion.ps1
    Author:	Sylvain Philipona
    Date:	26.05.2023
 	*****************************************************************************
    Modifications
 	Date  : 
 	Author: 
 	Reason: 
 	*****************************************************************************
.SYNOPSIS
    Delete or desactivate AD users based on data provided in a CSV
 	
.DESCRIPTION
    Imports a CSV file containing user data.
    Checks required headers, and check if the users has to be deleted or desactivate.
    Delete or desactivate the users.
    The users can be deleted only if they are already disabled.
    All actions are performed are recorded in another CSV file.
  	
.PARAMETER UsersCSV
    The CSV file containing all users to delete with theirs data

.PARAMETER ActionsCSV
    The CSV file that will be created / overwritted with the new created users 

.PARAMETER CSVDelimiter
    The delimiter of the CSV file

.OUTPUTS
    - A csv file logging all actions performed

.EXAMPLE
    .\Start-UsersDeletion.ps1 -UsersCSV "Z:\CSV\03-deletionUsers.csv" -ActionsCSV "Z:\CSV\06-deletedUsers.csv"

    User deletion : sylphilipon.
    User deletion : sylphilipon1.
    User deletion : sylphilipon2.
    User deletion : jocbolli.
    User deletion : nolpraz.
    User deletion : aledangelo.
    User deletion : test.

    User         Action  Comments
    ----         ------  --------
    sylphilipon  Success The user 'sylphilipon' and his home directory was successfully deleted.
    sylphilipon1 Success The user 'sylphilipon1' and his home directory was successfully deleted.
    sylphilipon2 Success The user 'sylphilipon2' and his home directory was successfully deleted.
    jocbolli     Success The user 'jocbolli' and his home directory was successfully deleted.
    nolpraz      Success The user 'nolpraz' and his home directory was successfully deleted.
    aledangelo   Success The user 'aledangelo' and his home directory was successfully deleted.
    test         Failed  The user 'test' doesn't exists.



    The actions are logged in the file 'Z:\CSV\06-deletedUsers.csv'.

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
$tagDisable = "Disable"
$tagDelete = "Delete"
$requiredHeaders = @($tagLogin, $tagDisable, $tagDelete)

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

# Delete all accounts
foreach($user in $users){

    # Display the user deletion message
    $userLogin = $user.$tagLogin
    Write-Host "User deletion : $userLogin." -ForegroundColor Green

    # Define the user actions data
    # This data will be completed according to the script actions performed
    $userActions = @{
        User = $userLogin
        Action = $null
        Comments = $null
    }

    # Check if the user login field isn't null or empty
    if(!$userLogin){
        $userActions["Action"] = "Failed"
        $userActions["Comments"] = "The '$tagLogin' field is empty."
        $allActions += [PSCustomObject]$userActions
        continue
    }

    # Check if the user exists
    $adUser = Get-ADUser -Filter {samAccountName -eq $userLogin}
    if(!($adUser)){

        # The user dosen't exists
        $userActions["Action"] = "Failed"
        $userActions["Comments"] = "The user '$userLogin' doesn't exists."
        $allActions += [PSCustomObject]$userActions
        continue
    }

    # Check if the account has to be disabled
    # The disable proprety has the priority over the deletion proprety
    if($user.$tagDisable -like "true"){

        # Disable the ad user
        $result = .\Disable-User.ps1 -Login $userLogin

        # If the user deactivation was successful
        if($result){
            $userActions["Action"] = "Success"
            $userActions["Comments"] = "The user '$userLogin' has been disabled."
        }
        else{
            $userActions["Action"] = "Failed"
            $userActions["Comments"] = "An unknow error has occured during the deactivation process of the '$userLogin' account."
        }
    }

    # Check if the account has to be deleted
    elseif($user.$tagDelete -like "true"){

        # Check if the user is disabled
        # Every users has to be disabled before deleted
        if($adUser.Enabled -eq $False){
            
            # Delete the user home directory
            $resultHD = .\Remove-HomeDirectory.ps1 -Login $userLogin

            ##### Result check #####
            
            # Delete the ad user
            $result = .\Remove-User.ps1 -Login $userLogin

            # Check if the user deletion was successfull
            if($result){

                $userActions["Action"] = "Success"

                # Check if the home directory deletion was successfull
                if($resultHD){
                    $userActions["Comments"] = "The user '$userLogin' and his home directory was successfully deleted."
                }
                else{
                    $userActions["Comments"] = "The user '$userLogin' successfully deleted, but he didn't have a home directory."
                }
            }
            else{
                $userActions["Action"] = "Failed"
                $userActions["Comments"] = "An unknow error has occured during the deletion process of the '$userLogin' account."
            }
        }
        else{
            $userActions["Action"] = "Failed"
            $userActions["Comments"] = "No actions were performed on the user '$userLogin'. The user has to be disabled before deleted."
        }
    }

    # Contradiction between the 'Disable' and the 'Delete' values
    else{
        $userActions["Action"] = "Failed"
        $userActions["Comments"] = "No actions were performed on the user '$userLogin'. There is a contradiction between the 'Disable' and the 'Delete' values."   
    }

    # Log the actions performed on the user
    $allActions += [PSCustomObject]$userActions
}

# Format the logged actions for better lisibility
$allActions = $allActions | Select-Object User, Action, Comments

# Check if the path is valid and the file extension is .csv
if(!(Test-Path $ActionsCSV -IsValid) -or [IO.Path]::GetExtension($ActionsCSV).ToLower() -ne ".csv"){
    Write-Host "The file path '$ActionsCSV' is not a valid path or is not in the .csv extension." -ForegroundColor Red
    $ActionsCSV = "$(Get-Location)\$DEFAULT_ACTIONS_FILE"
}

# Export the actions in a .csv
$allActions | Export-Csv -Path $ActionsCSV -NoTypeInformation -Encoding UTF8 -Delimiter $CSVDelimiter -Force
Write-Host ($allActions | Format-Table | Out-String)
Write-Host "The actions are logged in the file '$ActionsCSV'." -ForegroundColor Yellow