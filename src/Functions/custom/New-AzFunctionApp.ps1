
function New-AzFunctionApp {
    [OutputType([Microsoft.Azure.PowerShell.Cmdlets.Functions.Models.Api20180201.ISite])]
    [Microsoft.Azure.PowerShell.Cmdlets.Functions.Description('Creates a function app.')]
    [CmdletBinding(SupportsShouldProcess=$true, DefaultParametersetname="ByAppServicePlan")]
    param(
        [Parameter(ParameterSetName="Consumption", HelpMessage='The Azure subscription ID.')]
        [Parameter(ParameterSetName="ByAppServicePlan")]
        [Parameter(ParameterSetName="CustomDockerImage")]
        [Microsoft.Azure.PowerShell.Cmdlets.Functions.Runtime.DefaultInfo(Script='(Get-AzContext).Subscription.Id')]
        [ValidateNotNullOrEmpty()]
        [System.String]
        ${SubscriptionId},
        
        [Parameter(Mandatory=$true, ParameterSetName="Consumption", HelpMessage='The name of the resource group.')]
        [Parameter(Mandatory=$true, ParameterSetName="ByAppServicePlan")]
        [Parameter(Mandatory=$true, ParameterSetName="CustomDockerImage")]
        [ValidateNotNullOrEmpty()]
        [System.String]
        ${ResourceGroupName},
        
        [Parameter(Mandatory=$true, ParameterSetName="Consumption", HelpMessage='The name of the function app.')]
        [Parameter(Mandatory=$true, ParameterSetName="ByAppServicePlan")]
        [Parameter(Mandatory=$true, ParameterSetName="CustomDockerImage")]
        [ValidateNotNullOrEmpty()]
        [System.String]
        ${Name},
        
        [Parameter(Mandatory=$true, ParameterSetName="Consumption", HelpMessage='The name of the storage account.')]
        [Parameter(Mandatory=$true, ParameterSetName="ByAppServicePlan")]
        [Parameter(Mandatory=$true, ParameterSetName="CustomDockerImage")]
        [ValidateNotNullOrEmpty()]
        [System.String]
        ${StorageAccountName},

        [Parameter(ParameterSetName="Consumption", HelpMessage='Name of the existing App Insights project to be added to the function app.')]
        [Parameter(ParameterSetName="ByAppServicePlan")]
        [Parameter(ParameterSetName="CustomDockerImage")]
        [ValidateNotNullOrEmpty()]
        [System.String]
        [Alias("AppInsightsName")]
        ${ApplicationInsightsName},

        [Parameter(ParameterSetName="Consumption", HelpMessage='Instrumentation key of App Insights to be added.')]
        [Parameter(ParameterSetName="ByAppServicePlan")]
        [Parameter(ParameterSetName="CustomDockerImage")]
        [ValidateNotNullOrEmpty()]
        [System.String]
        [System.String]
        [Alias("AppInsightsKey")]
        ${ApplicationInsightsKey},

        [Parameter(Mandatory=$true, ParameterSetName="Consumption", HelpMessage='The location for the consumption plan.')]
        [ValidateNotNullOrEmpty()]
        [System.String]
        ${Location},

        [Parameter(Mandatory=$true, ParameterSetName="ByAppServicePlan", HelpMessage='The name of the service plan.')]
        [Parameter(Mandatory=$true, ParameterSetName="CustomDockerImage")]
        [ValidateNotNullOrEmpty()]
        [System.String]
        ${PlanName},

        [Parameter(ParameterSetName="ByAppServicePlan", HelpMessage='The OS to host the function app.')]
        [Parameter(ParameterSetName="Consumption")]
        [ArgumentCompleter([Microsoft.Azure.PowerShell.Cmdlets.Functions.Support.WorkerType])]
        [ValidateNotNullOrEmpty()]
        [System.String]
        # OS type (Linux or Windows)
        ${OSType},
        
        [Parameter(Mandatory=$true, ParameterSetName="ByAppServicePlan", HelpMessage='The function runtime.')]
        [Parameter(Mandatory=$true, ParameterSetName="Consumption")]
        [ArgumentCompleter([Microsoft.Azure.PowerShell.Cmdlets.Functions.Support.RuntimeType])]
        [ValidateNotNullOrEmpty()]
        [System.String]
        # Runtime type (DotNet, Node, Java, PowerShell or Python)
        ${Runtime},

        [Parameter(ParameterSetName="ByAppServicePlan", HelpMessage='The function runtime.')]
        [Parameter(ParameterSetName="Consumption")]
        [ValidateNotNullOrEmpty()]
        [System.String]
        ${RuntimeVersion},

        [Parameter(ParameterSetName="ByAppServicePlan", HelpMessage='The Functions version.')]
        [Parameter(ParameterSetName="Consumption")]
        [ArgumentCompleter([Microsoft.Azure.PowerShell.Cmdlets.Functions.Support.FunctionsVersionType])]
        [ValidateNotNullOrEmpty()]
        [System.String]
        # FunctionsVersion type (2 or 3). Default Functions version is defined in HelperFunctions.ps1
        ${FunctionsVersion},

        [Parameter(ParameterSetName="ByAppServicePlan", HelpMessage='Disable creating application insights resource during the function app creation. No logs will be available.')]
        [Parameter(ParameterSetName="Consumption")]
        [Parameter(ParameterSetName="CustomDockerImage")]
        [System.Management.Automation.SwitchParameter]
        [Alias("DisableAppInsights")]
        ${DisableApplicationInsights},
        
        [Parameter(Mandatory=$true, ParameterSetName="CustomDockerImage", HelpMessage='Linux only. Container image name from Docker Registry, e.g. publisher/image-name:tag.')]
        [ValidateNotNullOrEmpty()]
        [System.String]
        ${DockerImageName},

        [Parameter(ParameterSetName="CustomDockerImage", HelpMessage='The container registry user name and password. Required for private registries.')]
        [ValidateNotNullOrEmpty()]
        [PSCredential]
        ${DockerRegistryCredential},

        [Parameter(HelpMessage='Returns true when the command succeeds.')]
        [System.Management.Automation.SwitchParameter]
        ${PassThru},

        [Parameter(ParameterSetName="ByAppServicePlan", HelpMessage='Starts the operation and returns immediately, before the operation is completed. In order to determine if the operation has successfully been completed, use some other mechanism.')]
        [Parameter(ParameterSetName="Consumption")]
        [Parameter(ParameterSetName="CustomDockerImage")]
        [Microsoft.Azure.PowerShell.Cmdlets.Functions.Category('Runtime')]
        [System.Management.Automation.SwitchParameter]
        ${NoWait},
        
        [Parameter(ParameterSetName="ByAppServicePlan", HelpMessage='Runs the cmdlet as a background job.')]
        [Parameter(ParameterSetName="Consumption")]
        [Parameter(ParameterSetName="CustomDockerImage")]
        [Microsoft.Azure.PowerShell.Cmdlets.Functions.Category('Runtime')]
        [System.Management.Automation.SwitchParameter]
        ${AsJob},
        
        [Alias('AzureRMContext', 'AzureCredential')]
        [ValidateNotNull()]
        [Microsoft.Azure.PowerShell.Cmdlets.Functions.Category('Azure')]
        [System.Management.Automation.PSObject]
        ${DefaultProfile},

        [Parameter(DontShow)]
        [Microsoft.Azure.PowerShell.Cmdlets.Functions.Category('Runtime')]
        [System.Management.Automation.SwitchParameter]
        # Wait for .NET debugger to attach
        ${Break},

        <#
        [Parameter(DontShow)]
        [ValidateNotNull()]
        [Microsoft.Azure.PowerShell.Cmdlets.Functions.Category('Runtime')]
        [Microsoft.Azure.PowerShell.Cmdlets.Functions.Runtime.SendAsyncStep[]]
        # SendAsync Pipeline Steps to be appended to the front of the pipeline
        ${HttpPipelineAppend},

        [Parameter(DontShow)]
        [ValidateNotNull()]
        [Microsoft.Azure.PowerShell.Cmdlets.Functions.Category('Runtime')]
        [Microsoft.Azure.PowerShell.Cmdlets.Functions.Runtime.SendAsyncStep[]]
        # SendAsync Pipeline Steps to be prepended to the front of the pipeline
        ${HttpPipelinePrepend},
        #>

        [Parameter(DontShow)]
        [Microsoft.Azure.PowerShell.Cmdlets.Functions.Category('Runtime')]
        [System.Uri]
        # The URI for the proxy server to use
        ${Proxy},

        [Parameter(DontShow)]
        [ValidateNotNull()]
        [Microsoft.Azure.PowerShell.Cmdlets.Functions.Category('Runtime')]
        [System.Management.Automation.PSCredential]
        # Credentials for a proxy server to use for the remote call
        ${ProxyCredential},

        [Parameter(DontShow)]
        [Microsoft.Azure.PowerShell.Cmdlets.Functions.Category('Runtime')]
        [System.Management.Automation.SwitchParameter]
        # Use the default credentials for the proxy
        ${ProxyUseDefaultCredentials}
    )

    process {

        if ($PSBoundParameters.ContainsKey("AsJob"))
        {
            $null = $PSBoundParameters.Remove("AsJob")

            $modulePath = Join-Path $PSScriptRoot "../Az.Functions.psd1"

            Start-Job -ScriptBlock {
                param($arg, $modulePath)
                Import-Module $modulePath
                Az.Functions\New-AzFunctionApp @arg
            } -ArgumentList $PSBoundParameters, $modulePath
        }

        else 
        {
            # Remove bound parameters from the dictionary that cannot be process by the intenal cmdlets.
            $paramsToRemove = @(
                "StorageAccountName",
                "ApplicationInsightsName",
                "ApplicationInsightsKey",
                "Location",
                "PlanName",
                "OSType",
                "Runtime",
                "DisableApplicationInsights",
                "DockerImageName",
                "DockerRegistryCredential",
                "FunctionsVersion",
                "RuntimeVersion"
            )
            foreach ($paramName in $paramsToRemove)
            {
                if ($PSBoundParameters.ContainsKey($paramName))
                {
                    $null = $PSBoundParameters.Remove($paramName)
                }
            }

            $functionAppIsCustomDockerImage = $PsCmdlet.ParameterSetName -eq "CustomDockerImage"

            $appSettings = New-Object -TypeName System.Collections.Generic.List[System.Object]
            $siteCofig = New-Object -TypeName Microsoft.Azure.PowerShell.Cmdlets.Functions.Models.Api20180201.SiteConfig
            $functionAppDef = New-Object -TypeName Microsoft.Azure.PowerShell.Cmdlets.Functions.Models.Api20180201.Site

            ValidateFunctionName -Name $Name

            if (-not $functionAppIsCustomDockerImage)
            {
                if (-not $FunctionsVersion)
                {
                    $FunctionsVersion = $DefaultFunctionsVersion
                    Write-Verbose "FunctionsVersion not specified. Setting default FunctionsVersion to '$FunctionsVersion'." -Verbose
                }

                if (-not $OSType)
                {
                    $OSType = GetDefaultOSType -Runtime $Runtime
                    Write-Verbose "OSType for $Runtime is '$OSType'." -Verbose
                }

                if (-not $RuntimeVersion)
                {
                    # If not runtime version is provided, set the default version for the worker
                    $RuntimeVersion = GetDefaultRuntimeVersion -FunctionsVersion $FunctionsVersion -Runtime $Runtime -OSType $OSType
                    Write-Verbose "RuntimeVersion not specified. Setting default runtime version for $Runtime to '$RuntimeVersion'." -Verbose
                }

                if (($Runtime -eq "DotNet") -and ($RuntimeVersion -ne $FunctionsVersion))
                {
                    Write-Verbose "DotNet version is specified by FunctionsVersion. The value of the -RuntimeVersion will be set to $FunctionsVersion." -Verbose
                    $RuntimeVersion = $FunctionsVersion
                }

                ValidateRuntimeAndRuntimeVersion -FunctionsVersion $FunctionsVersion -Runtime $Runtime -RuntimeVersion $RuntimeVersion -OSType $OSType

                $runtimeWorker = $Runtime.ToLower()
                $appSettings.Add((NewAppSetting -Name 'FUNCTIONS_WORKER_RUNTIME' -Value "$runtimeWorker"))

                # Set Java version
                if ($Runtime -eq "Java")
                {
                    $JavaVersion = GetWorkerVersion -FunctionsVersion $FunctionsVersion -Runtime $Runtime -RuntimeVersion $RuntimeVersion -OSType $OSType
                    $siteCofig.JavaVersion = "$JavaVersion"
                }
            }

            $servicePlan = $null
            $consumptionPlan = $PsCmdlet.ParameterSetName -eq "Consumption"
            $OSIsLinux = $OSType -eq "Linux"
            
            if ($consumptionPlan)
            {
                ValidateConsumptionPlanLocation -Location $Location
                $functionAppDef.Location = $Location
            }
            else 
            {
                # Host function app in Elastic Premium or app service plan
                $servicePlan = GetServicePlan $PlanName
                if (-not $servicePlan)
                {
                    $errorMessage = "Service plan '$PlanName' does not exist."
                    $exception = [System.InvalidOperationException]::New($errorMessage)
                    ThrowTerminatingError -ErrorId "ServicePlanDoesNotExist" `
                                          -ErrorMessage $errorMessage `
                                          -ErrorCategory ([System.Management.Automation.ErrorCategory]::InvalidOperation) `
                                          -Exception $exception
                }

                if ($null -ne $servicePlan.Location)
                {
                    $Location = $servicePlan.Location
                }

                if ($null -ne $servicePlan.Reserved)
                {
                    $OSIsLinux = $servicePlan.Reserved
                }

                $functionAppDef.ServerFarmId = $servicePlan.Id
                $functionAppDef.Location = $Location
            }

            if ($OSIsLinux)
            {
                # These are the scenarios we currently support when creating a Docker container:
                # 1) In Consumption, we only support images created by Functions with a predefine runtime name and version, e.g., Python 3.7
                # 2) For App Service and Premium plans, a customer can specify a customer container image

                # Linux function app
                $functionAppDef.Kind = 'functionapp,linux'
                $functionAppDef.Reserved = $true

                # Bring your own container is only supported on App Service and Premium plans
                if ($DockerImageName)
                {
                    $functionAppDef.Kind = 'functionapp,linux,container'

                    $imageName = $DockerImageName.Trim().ToLower()
                    $appSettings.Add((NewAppSetting -Name 'DOCKER_CUSTOM_IMAGE_NAME' -Value $imageName))
                    $appSettings.Add((NewAppSetting -Name 'FUNCTION_APP_EDIT_MODE' -Value 'readOnly'))
                    $appSettings.Add((NewAppSetting -Name 'WEBSITES_ENABLE_APP_SERVICE_STORAGE' -Value 'false'))

                    $siteCofig.LinuxFxVersion = "DOCKER|$imageName"

                    # Parse the docker registry url, user name and password
                    $dockerRegistryServerUrl = ParseDockerImage -DockerImageName $DockerImageName
                    if ($dockerRegistryServerUrl)
                    {
                        $appSettings.Add((NewAppSetting -Name 'DOCKER_REGISTRY_SERVER_URL' -Value $dockerRegistryServerUrl))

                        if ($DockerRegistryCredential)
                        {
                            $appSettings.Add((NewAppSetting -Name 'DOCKER_REGISTRY_SERVER_USERNAME' -Value $DockerRegistryCredential.GetNetworkCredential().UserName))
                            $appSettings.Add((NewAppSetting -Name 'DOCKER_REGISTRY_SERVER_PASSWORD' -Value $DockerRegistryCredential.GetNetworkCredential().Password))
                        }
                    }
                }
                else
                {
                    $appSettings.Add((NewAppSetting -Name 'WEBSITES_ENABLE_APP_SERVICE_STORAGE' -Value 'true'))
                    $siteCofig.LinuxFxVersion = GetLinuxFxVersion -Runtime $Runtime -RuntimeVersion $RuntimeVersion
                }
            }
            else 
            {
                # Windows function app
                $functionAppDef.Kind = 'functionapp'

                # Set default Node version
                $defaultNodeVersion = GetFunctionAppDefaultNodeVersion -FunctionsVersion $FunctionsVersion -Runtime $Runtime -RuntimeVersion $RuntimeVersion
                $appSettings.Add((NewAppSetting -Name 'WEBSITE_NODE_DEFAULT_VERSION' -Value $defaultNodeVersion))
            }

            # Validate storage account and get connection string
            $connectionStrings = GetConnectionString -StorageAccountName $StorageAccountName
            $appSettings.Add((NewAppSetting -Name 'AzureWebJobsStorage' -Value $connectionStrings))
            $appSettings.Add((NewAppSetting -Name 'AzureWebJobsDashboard' -Value $connectionStrings))

            if (-not $functionAppIsCustomDockerImage)
            {
                $appSettings.Add((NewAppSetting -Name 'FUNCTIONS_EXTENSION_VERSION' -Value "~$FunctionsVersion"))
            }

            # If plan is not consumption or elastic premium, set always on
            $planIsElasticPremium = $servicePlan.SkuTier -eq 'ElasticPremium'
            if ((-not $consumptionPlan) -and $planIsElasticPremium)
            {
                $siteCofig.AlwaysOn = $true
            }

            # If plan is elastic premium or windows consumption, we need these app settings
            $IsWindowsConsumption = $consumptionPlan -and (-not $OSIsLinux)

            if ($planIsElasticPremium -or $IsWindowsConsumption)
            {
                $appSettings.Add((NewAppSetting -Name 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING' -Value $connectionStrings))
                $appSettings.Add((NewAppSetting -Name 'WEBSITE_CONTENTSHARE' -Value $Name.ToLower()))
            }

            if (-not $DisableAppInsights)
            {
                if ($ApplicationInsightsKey)
                {
                    $appSettings.Add((NewAppSetting -Name 'APPINSIGHTS_INSTRUMENTATIONKEY' -Value $ApplicationInsightsKey))
                }
                elseif ($ApplicationInsightsName)
                {
                    $appInsightsProject = GetApplicationInsightsProject -Name $ApplicationInsightsName
                    if (-not $appInsightsProject)
                    {
                        $errorMessage = "Failed to get application insights key for project name '$ApplicationInsightsName'. Please make sure the project exist."
                        $exception = [System.InvalidOperationException]::New($errorMessage)
                        ThrowTerminatingError -ErrorId "ApplicationInsightsProjectNotFound" `
                                            -ErrorMessage $errorMessage `
                                            -ErrorCategory ([System.Management.Automation.ErrorCategory]::InvalidOperation) `
                                            -Exception $exception
                    }

                    $appSettings.Add((NewAppSetting -Name 'APPINSIGHTS_INSTRUMENTATIONKEY' -Value $appInsightsProject.InstrumentationKey))
                }
                else
                {
                    # Create a new ApplicationInsights
                    try 
                    {
                        $newAppInsightsProject = Az.Functions.internal\New-AzAppInsights -ResourceGroupName $resourceGroupName `
                                                                                        -ResourceName $Name  `
                                                                                        -Location $functionAppDef.Location `
                                                                                        -Kind web `
                                                                                        -RequestSource "AzurePowerShell" `
                                                                                        -ErrorAction Stop
                        if ($newAppInsightsProject)
                        {
                            $appSettings.Add((NewAppSetting -Name 'APPINSIGHTS_INSTRUMENTATIONKEY' -Value $newAppInsightsProject.InstrumentationKey))
                        }                    
                    }
                    catch
                    {
                        $warningMessage = 'Unable to create the Application Insights for the Function App. Please use the Azure Portal to manually create and configure the Application Insights, if needed.'
                        Write-Warning $warningMessage
                    }
                }
            }

            # Set app settings and site configuration
            $siteCofig.AppSetting = $appSettings
            $functionAppDef.Config = $siteCofig
            $null = $PSBoundParameters.Add("SiteEnvelope", $functionAppDef)

            if ($PsCmdlet.ShouldProcess($Name, "Creating function app"))
            {
                # Save the ErrorActionPreference
                $currentErrorActionPreference = $ErrorActionPreference
                $ErrorActionPreference = 'Stop'

                try
                {
                    Az.Functions.internal\New-AzFunctionApp @PSBoundParameters

                    if ($consumptionPlan -and $OSIsLinux)
                    {
                        $message = "Your Linux function app '$Name', that uses a consumption plan has been successfully created but is not active until content is published using Azure Portal or the Functions Core Tools."
                        Write-Verbose $message -Verbose
                    }
                }
                catch
                {
                    $errorMessage = GetErrorMessage -Response $_

                    if ($errorMessage)
                    {
                        $exception = [System.InvalidOperationException]::New($errorMessage)
                        ThrowTerminatingError -ErrorId "FailedToCreateFunctionApp" `
                                              -ErrorMessage $errorMessage `
                                              -ErrorCategory ([System.Management.Automation.ErrorCategory]::InvalidOperation) `
                                              -Exception $exception
                    }

                    throw $_
                }
                finally
                {
                    # Reset the ErrorActionPreference
                    $ErrorActionPreference = $currentErrorActionPreference
                }
            }
        }
    }
}
