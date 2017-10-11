#################
# Configuration #
#################
$catalogSite = "https://giuleon.sharepoint.com/sites/apps"
$catalogName = "AppCatalog"
$catalogRelativePath = "sites/apps/AppCatalog"
#######
# End #
#######
#Get-Command -Module *PnP*
function GetRequest ($apiUrl, $webSession) {
    return Invoke-WebRequest -Uri $apiUrl -Method Get -WebSession $webSession
}

function replaceXml($lines, $old, $new) {
    $len = $lines.count
    for($i=0;$i-lt$len;$i++){
        $lines[$i] = $lines[$i] -replace $old, $new
    }
    return $lines
}

function setXmlMapping($xmlBody, $siteId, $webId, $listId, $fileId, $fileVersion, $skipDeployment) {
    # Replace the random token with a random guid
    $randomGuid = [guid]::NewGuid()
    #$xmlBody = $xmlBody.replace(new [RegExp]::('\\{randomId\\}', 'g'), $randomGuid)
    $xmlBody = replaceXml -lines $xmlBody -old '{randomId}' -new $randomGuid
    # Replace the site ID token with the actual site ID string
    #$xmlBody = xmlBody.replace(new RegExp('\\{siteId\\}', 'g'), siteId)
    $xmlBody = replaceXml -lines $xmlBody -old '{siteId}' -new $siteId
    # Replace the web ID token with the actual web ID string
    #$xmlBody = xmlBody.replace(new RegExp('\\{webId\\}', 'g'), webId)
    $xmlBody = replaceXml -lines $xmlBody -old '{webId}' -new $webId
    # Replace the list ID token with the actual list ID string
    #$xmlBody = xmlBody.replace(new RegExp('\\{listId\\}', 'g'), listId)
    $xmlBody = replaceXml -lines $xmlBody -old '{listId}' -new $listId
    # Replace the item ID token with the actual item ID number
    #$xmlBody = xmlBody.replace(new RegExp('\\{itemId\\}', 'g'), $fileId)
    $xmlBody = replaceXml -lines $xmlBody -old '{itemId}' -new $fileId
    # Replace the file version token with the actual file version number
    #$xmlBody = xmlBody.replace(new RegExp('\\{fileVersion\\}', 'g'), $fileVersion)
    $xmlBody = replaceXml -lines $xmlBody -old '{fileVersion}' -new $fileVersion
    # Replace the skipFeatureDeployment token with the skipFeatureDeployment option
    #$xmlBody = xmlBody.replace(new RegExp('\\{skipFeatureDeployment\\}', 'g'), $skipDeployment)
    $xmlBody = replaceXml -lines $xmlBody -old '{skipFeatureDeployment}' -new $skipDeployment
    return $xmlBody;
}

Write-Host ***************************************** -ForegroundColor Yellow
Write-Host * Uploading the sppkg on the AppCatalog * -ForegroundColor Yellow
Write-Host ***************************************** -ForegroundColor Yellow
$packageConfig = Get-Content -Raw -Path .\config\package-solution.json | ConvertFrom-Json
$packagePath = Join-Path "sharepoint/" $packageConfig.paths.zippedPackage -Resolve
$skipFeatureDeployment = $packageConfig.solution.skipFeatureDeployment
<#
Connect-PnPOnline –Url $catalogSite –Credentials $cred
Add-PnPFile -Path $packagePath -Folder $catalogName

Write-Host *************************************************** -ForegroundColor Yellow
Write-Host * The SPFx solution has been succesfully deployed * -ForegroundColor Yellow
Write-Host *************************************************** -ForegroundColor Yellow
#>

# Connect to SharePoint Online
$targetSite = "https://giuleon.sharepoint.com/sites/apps"
$targetSiteUri = [System.Uri]$targetSite
 
Connect-PnPOnline $targetSite -Credentials giuleon
 
# Retrieve the client credentials and the related Authentication Cookies
$context = (Get-PnPWeb).Context
$credentials = $context.Credentials
$authenticationCookies = $credentials.GetAuthenticationCookie($targetSiteUri, $true)
 
# Set the Authentication Cookies and the Accept HTTP Header
$webSession = New-Object Microsoft.PowerShell.Commands.WebRequestSession  
$webSession.Cookies.SetCookies($targetSiteUri, $authenticationCookies)
$webSession.Headers.Add("Accept", "application/json;odata=verbose")
 
# Set request variables
#$apiUrl = "$targetSite" + "_api/web/currentuser"
$apiUrl = "$targetSite" + "/_api/site?$"+"select=Id"

# Make the REST request
$webRequest =  GetRequest -apiUrl $apiUrl -webSession $webSession # Invoke-WebRequest -Uri $apiUrl -Method Get -WebSession $webSession
$response = $webRequest.Content | ConvertFrom-Json
$siteId = $response.d.Id
Write-Host $response.d.Id

# Retrieving webId and listId
$apiUrl = "$targetSite" + "/_api/web/getList('$catalogRelativePath')?$"+"select=Id,ParentWeb/Id&$"+"expand=ParentWeb"
$webRequest =  GetRequest -apiUrl $apiUrl -webSession $webSession # Invoke-WebRequest -Uri $apiUrl -Method Get -WebSession $webSession
$response = $webRequest.Content | ConvertFrom-Json
$webId = $response.d.ParentWeb.Id
$listId = $response.d.Id
Write-Host $response.d.Id

# Get the ListItemAllFields Id and Version
$fileName = $packageConfig.paths.zippedPackage.Substring($packageConfig.paths.zippedPackage.LastIndexOf("/")+1)
$apiUrl = "$targetSite" + "/_api/web/GetFolderByServerRelativeUrl('AppCatalog')/Files('$fileName')?$"+"expand=ListItemAllFields&$" + "select=ListItemAllFields/ID,ListItemAllFields/owshiddenversion"
$webRequest =  GetRequest -apiUrl $apiUrl -webSession $webSession # Invoke-WebRequest -Uri $apiUrl -Method Get -WebSession $webSession
$response = $webRequest.Content -replace '"id":', '"id_":' | ConvertFrom-Json
$fileId = $response.d.ListItemAllFields.id_
$fileVersion = $response.ListItemAllFields.owshiddenversion
Write-Host $response.d.ListItemAllFields.id_

# Read the xml
$xmlBody = Get-Content DeplosSPFxToAppCatalogRequestBody.xml
$xmlBody = setXmlMapping -xmlBody $xmlBody -siteId $siteId -webId $webId -listId $listId -fileId $fileId -fileVersion $fileVersion -skipDeployment $skipFeatureDeployment
Write-Host $xmlBody

# Consume the JSON result
#$jsonLibrary = $webRequest.Content | ConvertFrom-Json
#Write-Host $jsonLibrary.d.Title

