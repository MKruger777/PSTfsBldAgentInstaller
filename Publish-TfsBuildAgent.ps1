

function Publish-TfsBuildAgent()
{
    <#
        .SYNOPSIS
        This cmd-let aims to automate the build agent provisioning. 
        In the case where you provision a new build server to execute x-amount of build, this will take care of setting up
        the required build agents on the server in an automated manner.

        The script can also download the agent. This is allready tested and follows in v2.

        Requirements:
         - The powershell sessions should run with elevated privilidges, as a windows services will be installed.
         - The account that executed the scripts needs permissions to add agents to pools.
         - See to it that the passed credentials for the service is valid

        .PARAMETER AgentName
        Specify the name under which the agent will be registered.. 

        .PARAMETER TfsBldAgentSrcPath
        Specify the location path where the Tfs build agent installer can be retrieved. 
        
        .PARAMETER TfsServerUrl
        Specify the Tfs server Url. 

        .PARAMETER TfsServiceAccount
        Specify the user account under which the service will run. 

        .PARAMETER TfsServiceAccountPwd
        Specify the user account's password  under which the service will run. 

        .PARAMETER TfsTargetBuildPool
        Specify the pool name where the agent will be registered. 

        .EXAMPLE
        ./Publish-TfsBuildAgent -AgentName 'AgentUnattend' -TfsBldAgentSrcPath 'D:\vsts-agent-win7-x64-2.122.1.zip' -TfsServerUrl 'http://t800:8080/tfs' -TfsServiceAccount 'theusername' -TfsServiceAccountPwd 'thepassword' -TfsTargetBuildPool 'default'
    #> 
        param(
        [Parameter(Mandatory=$true)]
        [string]$AgentName,
        [Parameter(Mandatory=$true)]
        [string]$TfsBldAgentSrcPath,
        [Parameter(Mandatory=$true)]
        [string]$TfsServerUrl,
        [Parameter(Mandatory=$true)]
        [string]$TfsServiceAccount,
        [Parameter(Mandatory=$true)]
        [string]$TfsServiceAccountPwd,
        [Parameter(Mandatory=$true)]
        [string]$TfsTargetBuildPool        
    )

    try
    {
        $TargetDir =  Split-path -Path  $script:MyInvocation.MyCommand.Path
        Write-Host 'Fetching Tfs build installer ...' -ForegroundColor Cyan 
        Copy-Item $TfsBldAgentSrcPath $TargetDir
        Write-Host 'done' -ForegroundColor Green 
        $TfsAgentToUnzip = Join-Path -Path $TargetDir -ChildPath (Split-Path $TfsBldAgentSrcPath -leaf)#'vsts-agent-win7-x64-2.122.1.zip'

        Add-Type -AssemblyName System.IO.Compression.FileSystem
        Write-Host 'Unzipping Tfs build installer ...' -ForegroundColor Cyan
        Unzip $TfsAgentToUnzip $TargetDir
        Write-Host 'done' -ForegroundColor Green 

        Set-Location -Path $TargetDir
        Write-Host 'Starting config of Tfs build installer ...' -ForegroundColor Cyan
        .\config.cmd --unattended --url $TfsServerUrl --auth integrated --pool $TfsTargetBuildPool --agent $AgentName --runAsService --windowsLogonAccount $TfsServiceAccount --windowsLogonPassword $TfsServiceAccountPwd
        Write-Host 'done' -ForegroundColor Green 
    }
    catch
    {
        Write-Host "Error occured while installing the Tfs build agent!"
        Write-Host $error[0]
    }
}

function Unzip
{
    param([string]$zipfile, [string]$outpath)
    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipfile, $outpath)
}

Publish-TfsBuildAgent -AgentName 'AgentUnattend' -TfsBldAgentSrcPath 'D:\vsts-agent-win7-x64-2.122.1.zip' -TfsServerUrl 'http://t800:8080/tfs' -TfsServiceAccount 'T800\alice' -TfsServiceAccountPwd 'A!b2C#d4' -TfsTargetBuildPool 'default'
