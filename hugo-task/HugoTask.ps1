[CmdletBinding()]
param()

Trace-VstsEnteringInvocation $MyInvocation
try {
    # Add Localization:
    #   Import-VstsLocStrings "$PSScriptRoot\Task.json"

    # Get the inputs.
    [string]$source = Get-VstsInput -Name Source
    [string]$destination = Get-VstsInput -Name Destination
    [string]$hugoVersion = Get-VstsInput -Name HugoVersion
    [bool]$extendedVersion = Get-VstsInput -Name ExtendedVersion
    [string]$baseURL = Get-VstsInput -Name BaseURL

    [bool]$buildDrafts = Get-VstsInput -Name BuildDrafts -AsBool
    [bool]$buildExpired = Get-VstsInput -Name BuildExpired -AsBool
    [bool]$buildFuture = Get-VstsInput -Name BuildFuture -AsBool
    [bool]$uglyURLs = Get-VstsInput -Name UglyURLs -AsBool

    Assert-VstsPath -LiteralPath $source -PathType Container

    # Import the helpers.
    $here = $PSScriptRoot # this helps in quick debugging
    . $here\Select-HugoVersion.ps1
    . $here\Get-HugoExecutable.ps1
    . $here\Invoke-Hugo.ps1


    $versionInfo = Select-HugoVersion -PreferredVersion $hugoVersion -ExtendedVersion $extendedVersion
    if (!$versionInfo) {
        Write-Error "Something bad happened while querying Hugo versions in GitHub"
        return
    }
    [string]$hugoExePath = Get-HugoExecutable -SourceUrl $versionInfo.DownloadURL -Version $versionInfo.Version
    Invoke-Hugo -hugoExePath $hugoExePath -source $source -destination $destination -baseURL $baseURL -buildDrafts $buildDrafts -buildExpired $buildExpired -buildFuture $buildFuture -uglyURLs $uglyURLs


} finally {
    Trace-VstsLeavingInvocation $MyInvocation
}