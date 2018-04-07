

function Publish-TfsBuildAgent()
{
    <#
        .SYNOPSIS
        As part of  the release cycle's build machine reconfiguration - it is required to update certain values in the Mickey XMD. 
        This cmd-let forms part of this action by handling the reading of values from the XMD.

        The script either get the XML passed to it (this is prefered to enhance performance, in contrast to reading the XML each time)
        OR!
        The path required for the environment that is applicabile, is read from config and the XML read into memory.

        .PARAMETER Path
        Specify the path to the XMD that will be read. 

        .PARAMETER Attribute
        Specify the xml attribute that needs to be found and read. 
        
        .PARAMETER Xml
        This paramter passes XML that will be used to read the Atribute from. This aims to avoid multiple reading of the XMD. 

        .EXAMPLE
        .\Get-ToplineXmdValue.ps1 "//TOPLINERELEASERPLUS/GLOBAL/@OMGEVING" "$loadedXML"
    #> 
        param(
        [Parameter(Mandatory=$true)]
        [string]$AgentName,
        [Parameter(Mandatory=$true)]
        [string]$InstallerSrcDir,
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
        $TfsAgentInstallerLocation = 'D:\vsts-agent-win7-x64-2.122.1.zip'
        $TargetDir =  Split-path -Path $MyInvocation.MyCommand.Path
        Copy-Item $TfsAgentInstallerLocation $TargetDir
        $TfsAgentToUnzip = Join-Path -Path $TargetDir -ChildPath 'vsts-agent-win7-x64-2.122.1.zip'

        Add-Type -AssemblyName System.IO.Compression.FileSystem
        Unzip $TfsAgentToUnzip $TargetDir

        #start unattended config
        $AgentName = 'UnattendedAlice'
        $TfsServer = 'http://t800:8080/tfs'

        Set-Location -Path $TargetDir
        #.\config.cmd --unattended --url $TfsServer --auth integrated --pool default --agent $AgentName --runAsService --windowsLogonAccount 'T800\alice' --windowsLogonPassword 'A!b2C#d4'
        .\config.cmd --unattended --url $TfsServer --auth integrated --pool $ta --agent $AgentName --runAsService --windowsLogonAccount 'T800\alice' --windowsLogonPassword 'A!b2C#d4'
    }
    catch
    {
        Write-Host "Error occured while retrieving a ToplineXmdValue value!"
        Write-Host "Attribute passed = $Attribute"
        Write-Host $error[0]
    }
}

function Unzip
{
    param([string]$zipfile, [string]$outpath)
    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipfile, $outpath)
}

