function Select-HugoVersion {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$PreferredVersion)

    Trace-VstsEnteringInvocation $MyInvocation
    try {

        Write-Verbose "Querying Hugo GitHub releases"

        # ask GitHub for Releases
        if ($PreferredVersion -eq "latest") {
            $availableReleases = Invoke-GitHubAPI "/repos/gohugoio/hugo/releases?draft=false"
        } else {
            $availableReleases = Invoke-GitHubAPI "/repos/gohugoio/hugo/releases/tags/v${PreferredVersion}"            
        }
        $release = $availableReleases | where { (-not $_.draft) -and (-not $_.prerelease) } | select id,name -First 1
        
        Write-Verbose "Found release $( $release.name )"

        $assets = Invoke-GitHubAPI "/repos/gohugoio/hugo/releases/$( $release.id )/assets"
        $win64hugo = $assets | where { $_.name -like '*Windows*64*' }

        return @{ Version = $release.name; DownloadURL = $win64hugo.browser_download_url }
        
    } finally {
        Trace-VstsLeavingInvocation $MyInvocation
    }
}


function Invoke-GitHubAPI($api) {
    # stick with v3 API
    $x = Invoke-WebRequest -Uri "https://api.github.com${api}" -Headers @{"accept"="application/vnd.github.v3+json"} -UseBasicParsing
    return $x.Content | ConvertFrom-Json    
}