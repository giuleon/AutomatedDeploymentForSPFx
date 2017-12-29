#################
# Configuration #
#################
Param(
    [string]$username, # => Office 365 Username
    [string]$psw, # => Office 365 Password
    [string]$cdnSite, # => CDN SharePoint site "https://giuleon.sharepoint.com/"
    [string]$cdnLib, # => Document library and eventual folders "cdn/SPFx-deploy"
    [string]$releaseFolder # => TFS folder where the files are extracted
)
#######
# End #
#######
Write-Host No problem reading $env:username or $username
Write-Host But I cannot read $env:psw
Write-Host But I can read $psw "(but the log is redacted so I do not spoil the secret)"

Write-Host ************************************************************************************** -ForegroundColor Yellow
Write-Host * Reading the cdnBasePath from write-manifests.json and collectiong the bundle files * -ForegroundColor Yellow
Write-Host ************************************************************************************** -ForegroundColor Yellow
$currentLocation = Get-Location | Select-Object -ExpandProperty Path
Write-Host ($currentLocation + $releaseFolder + "\config\copy-assets.json")
$cdnConfig = Get-Content -Raw -Path ($currentLocation + $releaseFolder + "\config\copy-assets.json") | ConvertFrom-Json
$bundlePath = ($currentLocation + $releaseFolder + "\" + $cdnConfig.deployCdnPath) #Convert-Path $cdnConfig.deployCdnPath
$files = Get-ChildItem $bundlePath\*.*

Write-Host **************************************** -ForegroundColor Yellow
Write-Host Uploading the bundle on Office 365 CDN * -ForegroundColor Yellow
Write-Host **************************************** -ForegroundColor Yellow
$sp = $psw | ConvertTo-SecureString -AsPlainText -Force
$plainCred = New-Object system.management.automation.pscredential -ArgumentList $username, $sp
Connect-PnPOnline $cdnSite -Credentials $plainCred
foreach ($file in $files) {
    $fullPath = $file.DirectoryName + "\" + $file.Name
    Add-PnPFile -Path $fullPath -Folder $cdnLib
}