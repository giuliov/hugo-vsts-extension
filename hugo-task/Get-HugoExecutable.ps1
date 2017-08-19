function Get-HugoExecutable {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$SourceUrl,
        [Parameter(Mandatory = $true)]
        [string]$Version)

    Trace-VstsEnteringInvocation $MyInvocation

    $hugoFolder = "${env:TEMP}\hugotask_${Version}"
    $hugoExe = "${hugoFolder}\hugo.exe"
    Write-Debug "Hugo executable searched at ${hugoExe}"
    
    try {

        # do we have it?
        if (-not (Test-Path $hugoExe)) {

            Write-Verbose "Cached hugo version ${Version} not found: downloading from GitHub"
            
            New-Item -Path $hugoFolder -ItemType Directory -Force | Out-Null
            $hugoZip = "${hugoFolder}\hugo.zip"
            Invoke-WebRequest -Uri $SourceUrl -OutFile $hugoZip -UseBasicParsing

            Write-Verbose "Download complete: unzipping"

            [System.Reflection.Assembly]::LoadWithPartialName('System.IO.Compression.FileSystem') | Out-Null
            [System.IO.Compression.ZipFile]::ExtractToDirectory($hugoZip, $hugoFolder)

            Write-Verbose "Unzip completed: cleanup."

            Remove-Item $hugoZip -Force | Out-Null
        }
        return $hugoExe
            
    } finally {
        Trace-VstsLeavingInvocation $MyInvocation
    }
}
