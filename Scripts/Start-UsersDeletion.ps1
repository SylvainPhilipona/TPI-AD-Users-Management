
param(
    [ValidateNotNullOrEmpty()]
    [string]$Login = "sylphilipon"
)

# Check if the user exists
if(Get-ADUser -Filter {samAccountName -eq $Login}){

    Write-Host "The user $Login exists !" -ForegroundColor Green
}
else{

    Write-Host "The user $Login dosen't exists !" -ForegroundColor Red
}