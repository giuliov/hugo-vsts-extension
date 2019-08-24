function Invoke-Hugo {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$hugoExePath,
        [Parameter(Mandatory = $true)]
        [string]$source,
        [string]$destination,
        [string]$baseURL,
    
        [bool]$buildDrafts,
        [bool]$buildExpired,
        [bool]$buildFuture,
        [bool]$uglyURLs,
        [bool]$minify
    )

    Trace-VstsEnteringInvocation $MyInvocation
    try {

        $flags = ""
        $flags += " --source ${source}"        
        if (![string]::IsNullOrWhiteSpace($baseURL)) { $flags += " --baseURL ${baseURL}" }
        if (![string]::IsNullOrWhiteSpace($destination)) {
            Write-Verbose "No destination specified, Hugo will assume 'public'"
            $flags += " --destination ${destination}"
        }
        
        if ($buildDrafts) { $flags += " --buildDrafts" }
        if ($buildExpired) { $flags += " --buildExpired" }
        if ($buildFuture) { $flags += " --buildFuture" }
        if ($uglyURLs) { $flags += " --uglyURLs" }
        if ($minify) { $flags += " --minify" }

        $implicitFlags = " --enableGitInfo --i18n-warnings --verbose"
        
        Invoke-VstsTool -FileName $hugoExePath -Arguments "${flags} ${implicitFlags}" -RequireExitCodeZero
        #Invoke-Expression "${hugoExePath} ${flags} ${implicitFlags}"
        
    } finally {
        Trace-VstsLeavingInvocation $MyInvocation
    }
}
