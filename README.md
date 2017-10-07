# Automated deployment of your SharePoint Framework solution to Office 365 CDN

The sample provide a Powershell script to include in your SharePoint Framework solution which allow to have an automated deployment on Office 365 CDN

***
## Prerequirements

In order to use properly this script, is necessary install the [PnP Powershell](https://github.com/SharePoint/PnP-PowerShell)

## How to use it

* Include the powershell file **DeploySPFxToO365CDN.ps1** directly into the root of your SharePoint Framework solution.

* Setup the Office 365 CDN url `cdnBasePath` in the `write-manifest.json`.

* Fill out the parameters contained in the configuration comments of **DeploySPFxToO365CDN.ps1**:

    | Parameter     | Value         |
    | ------------- |:-------------:|
    | $cdnSite      | https://`<tenant>`.sharepoint.com/... |
    | $cdnLib       | `<Document Library Name>` |
    | $catalogSite  | https://`<tenant>`.sharepoint.com/... |
    | $catalogName  | `AppCatalog`  |

* Run `gulp bundle --ship`

* Run `gulp package-solution --ship`

* Run **DeploySPFxToO365CDN.ps1**, set the windows credential manager on your machine to avoid the Office 365 login everytime. [more detail here](https://github.com/SharePoint/PnP-PowerShell/wiki/How-to-use-the-Windows-Credential-Manager-to-ease-authentication-with-PnP-PowerShell)

* Last step open the App Catalog and trigger the deploy for your SPFx solution

> For different environments you can create more files properly configured as this example:
> - DeploySPFxToO365CDN.**Test**.ps1
> - DeploySPFxToO365CDN.**QA**.ps1
> - DeploySPFxToO365CDN.**Production**.ps1

***
## For More Info Read My Blog Post
[http://www.delucagiuliano.com/automated-deployment-of-your-sharepoint-framework-solution-to-office-365-cdn](http://www.delucagiuliano.com/automated-deployment-of-your-sharepoint-framework-solution-to-office-365-cdn)