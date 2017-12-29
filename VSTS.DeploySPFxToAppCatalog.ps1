#################
# Configuration #
#################
Param(
    [string]$username, # => Office 365 Username
    [string]$psw, # => Office 365 Password
    [string]$catalogSite, # => App Catalog site "https://giuleon.sharepoint.com/sites/apps"
    [string]$releaseFolder # => TFS folder where the files are extracted
)
#######
# End #
#######
Write-Host No problem reading $env:username or $username
Write-Host But I cannot read $env:psw
Write-Host But I can read $psw "(but the log is redacted so I do not spoil the secret)"

Write-Host ***************************************** -ForegroundColor Yellow
Write-Host * Uploading the sppkg on the AppCatalog * -ForegroundColor Yellow
Write-Host ***************************************** -ForegroundColor Yellow
$currentLocation = Get-Location | Select-Object -ExpandProperty Path
Write-Host ($currentLocation + $releaseFolder + "\config\package-solution.json")
$packageConfig = Get-Content -Raw -Path ($currentLocation + $releaseFolder + "\config\package-solution.json") | ConvertFrom-Json
$packagePath = Join-Path ($currentLocation + $releaseFolder + "\sharepoint\") $packageConfig.paths.zippedPackage -Resolve #Join-Path "sharepoint/" $packageConfig.paths.zippedPackage -Resolve
Write-Host "packagePath: $packagePath"
$skipFeatureDeployment = $packageConfig.solution.skipFeatureDeployment

# Connect-PnPOnline $catalogSite -Credentials (Get-Credential)
$sp = $psw | ConvertTo-SecureString -AsPlainText -Force
$plainCred = New-Object system.management.automation.pscredential -ArgumentList $username, $sp
Connect-PnPOnline $catalogSite -Credentials $plainCred

# Adding and publishing the App package
If ($skipFeatureDeployment -ne $true) {
  Write-Host "skipFeatureDeployment = false"
  Add-PnPApp -Path $packagePath -Publish -Overwrite
  Write-Host *************************************************** -ForegroundColor Yellow
  Write-Host * The SPFx solution has been succesfully uploaded and published to the AppCatalog * -ForegroundColor Yellow
  Write-Host *************************************************** -ForegroundColor Yellow
}
Else {
  Write-Host "skipFeatureDeployment = true"
  Add-PnPApp -Path $packagePath -SkipFeatureDeployment -Publish -Overwrite
  Write-Host *************************************************** -ForegroundColor Yellow
  Write-Host * The SPFx solution has been succesfully uploaded and published to the AppCatalog * -ForegroundColor Yellow
  Write-Host *************************************************** -ForegroundColor Yellow
}