<#
  Sp3ctre4 - 2/9/2025 - Pulls from the specified CSV File and Bulk creates AD Users
  An example CSV File is provided in this repo.
#>

# put the path to the csv file here
$import_users = Import-Csv -Path c:\minionexample.csv

$import_users | ForEach-Object {New-ADUser -Name $($_.First + " " + $_.Last) -GivenName $_.First -Surname $_.Last -Department $_.Department -EmployeeID $_.EmployeeID -DisplayName $($_.First + " " + $_.Last) -UserPrincipalName $_.UserPrincipalName -SamAccountName $_.samAccountName -AccountPassword $(ConvertTo-SecureString $_.Password -AsPlainText -Force) -Title $_.Title -Path $_.OU -Enabled $True}
