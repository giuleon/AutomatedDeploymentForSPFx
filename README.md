# Automated deployment of your SharePoint Framework solution to Office 365 CDN

The sample provide a Powershell script to include in your SharePoint Framework solution which allow to have an automated deployment on Office 365 CDN

***
## Prerequirements

In order to use properly this script, is necessary install the [PnP Powershell](https://github.com/SharePoint/PnP-PowerShell)

## How to use it

* Include the powershell files **DeploySPFxToO365CDN.ps1** and **DeploySPFxToAppCatalog.ps1** directly into the root of your SharePoint Framework solution. The first file uploads the SPFx bundle on Office 365, the second uploads and deploys the sppkg into the App Catalog.

* Setup the Office 365 CDN url `cdnBasePath` in the `write-manifest.json`.

* Fill out the parameters contained in the configuration comments of **DeploySPFxToO365CDN.ps1** and **DeploySPFxToAppCatalog.ps1**:

    | Parameter     | Value         |
    | ------------- |:-------------:|
    | $cdnSite      | https://`<tenant>`.sharepoint.com/... |
    | $cdnLib       | `<Document Library Name>` |
    | $catalogSite  | https://`<tenant>`.sharepoint.com/... |

* Run `gulp bundle --ship`

* Run `gulp package-solution --ship`

* Run **DeploySPFxToO365CDN.ps1**, set the windows credential manager on your machine to avoid the Office 365 login everytime. [more detail here](https://github.com/SharePoint/PnP-PowerShell/wiki/How-to-use-the-Windows-Credential-Manager-to-ease-authentication-with-PnP-PowerShell)

* Run **DeploySPFxToAppCatalog.ps1** and your SPFx solution is ready to go

> You can also include these scripts in your TFS and configure properly the variables about the release definitions

***
## For More Info Read My Blog Post
[http://www.delucagiuliano.com/automated-deployment-of-your-sharepoint-framework-solution-to-office-365-cdn](http://www.delucagiuliano.com/automated-deployment-of-your-sharepoint-framework-solution-to-office-365-cdn)

***
## In order to configure the continuous integration and deployment on Visual Studio Team Services, follow the steps on my blog post

> use the following files:
> * **VSTS.DeploySPFxToAppCatalog.ps1**
> * **VSTS.DeploySPFxToO365CDN.ps1**

[http://www.delucagiuliano.com/continuous-integration-and-deployment-for-your-sharepoint-framework-solutions](http://www.delucagiuliano.com/continuous-integration-and-deployment-for-your-sharepoint-framework-solutions)

### Demo available here:
[https://github.com/giuleon/spfx-almapi](https://github.com/giuleon/spfx-almapi)