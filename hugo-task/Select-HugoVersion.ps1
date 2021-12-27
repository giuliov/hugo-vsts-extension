function Select-HugoVersion
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string] $PreferredVersion,
        [Parameter(Mandatory = $false)]
        [bool] $ExtendedVersion = $false
    )

    Trace-VstsEnteringInvocation $MyInvocation
    try {

        Write-Verbose "Querying Hugo GitHub releases"

        # ask GitHub for Releases
        if ($PreferredVersion -eq "latest") {
            $availableReleases = Invoke-GitHubAPI "/repos/gohugoio/hugo/releases?draft=false"
        } else {
            $availableReleases = Invoke-GitHubAPI "/repos/gohugoio/hugo/releases/tags/v${PreferredVersion}"
        }
        $release = $availableReleases | where { (-not $_.draft) -and (-not $_.prerelease) } | select id,name,assets -First 1

        Write-Verbose "Found release $( $release.name )"

        $win64hugo = $release.assets | where { $_.name -like '*Windows-64*' }

        # extended since 0.43
        $DownloadURL = $win64hugo.browser_download_url
        if ($DownloadURL -isnot [string]) {
            if ($ExtendedVersion) {
                $DownloadURL = $DownloadURL | where { $_ -like '*extended*' }
            } else {
                $DownloadURL = $DownloadURL | where { $_ -notlike '*extended*' }
            }
        }

        return @{ Version = $release.name; DownloadURL = $DownloadURL }

    } finally {
        Trace-VstsLeavingInvocation $MyInvocation
    }
}


function Invoke-GitHubAPI($api) {
    # github api now only accepts TLS 1.2, see https://githubengineering.com/crypto-removal-notice/
    [System.Net.ServicePointManager]::SecurityProtocol = @("Tls12")
    # stick with v3 API
    $x = Invoke-WebRequest -Uri "https://api.github.com${api}" -Headers @{"accept"="application/vnd.github.v3+json"} -UseBasicParsing
    return $x.Content | ConvertFrom-Json
}

<#
Select-HugoVersion 'latest' $false
Select-HugoVersion 'latest' $true
Select-HugoVersion '0.43' $false
Select-HugoVersion '0.43' $true
Select-HugoVersion '0.31' $false
Select-HugoVersion '0.31' $true
#>
