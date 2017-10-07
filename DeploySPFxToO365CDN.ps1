#################
# Configuration #
#################
$cdnSite = 'https://giuleon.sharepoint.com/'
$cdnLib = 'cdn/SPFx-youtube'
$catalogSite = 'https://giuleon.sharepoint.com/sites/apps'
$catalogName = 'AppCatalog'
#######
# End #
######à

Write-Host ************************************************************************************** -ForegroundColor Yellow
Write-Host * Reading the cdnBasePath from write-manifests.json and collectiong the bundle files * -ForegroundColor Yellow
Write-Host ************************************************************************************** -ForegroundColor Yellow
$cdnConfig = Get-Content -Raw -Path .\config\copy-assets.json | ConvertFrom-Json
$bundlePath = Convert-Path $cdnConfig.deployCdnPath
$files = Get-ChildItem $bundlePath\*.*

Write-Host **************************************** -ForegroundColor Yellow
Write-Host Uploading the bundle on Office 365 CDN * -ForegroundColor Yellow
Write-Host **************************************** -ForegroundColor Yellow
Connect-PnPOnline –Url $cdnSite –Credentials (Get-Credential)
foreach ($file in $files) {
    $fullPath = $file.DirectoryName + '\' + $file.Name
    Add-PnPFile -Path $fullPath -Folder $cdnLib
}

Write-Host ***************************************** -ForegroundColor Yellow
Write-Host * Uploading the sppkg on the AppCatalog * -ForegroundColor Yellow
Write-Host ***************************************** -ForegroundColor Yellow
$packageConfig = Get-Content -Raw -Path .\config\package-solution.json | ConvertFrom-Json
$packagePath = Join-Path 'sharepoint/' $packageConfig.paths.zippedPackage -Resolve

Connect-PnPOnline –Url $catalogSite –Credentials (Get-Credential)
Add-PnPFile -Path $packagePath -Folder $catalogName

Write-Host *************************************************** -ForegroundColor Yellow
Write-Host * The SPFx solution has been succesfully deployed * -ForegroundColor Yellow
Write-Host *************************************************** -ForegroundColor Yellow
