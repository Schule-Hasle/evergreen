Function Get-GoogleChromeVersion {
    <#
        .SYNOPSIS
            Returns the available Google Chrome versions.

        .DESCRIPTION
            Returns the available Google Chrome versions across all platforms and channels by querying the offical Google version JSON.

        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy
        
        .LINK
            https://github.com/aaronparker/Get.Software

        .PARAMETER Platform
            Specify the platform/s to return versions for. Supports all available platforms - Windows, Linux, macOS, iOS, Android etc.

        .PARAMETER Channel
            Specify the release channel to return Chrome version for - stable, beta, dev, canary etc.

        .EXAMPLE
            Get-GoogleChromeVersion

            Description:
            Returns the available Google Chrome versions across all platforms and channels.

        .EXAMPLE
            Get-GoogleChromeVersion -Platform win64 -Channel stable

            Description:
            Returns the Google Chrome version for the current stable release on 64-bit Windows.
    #>
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $False)]
        [string] $Uri = "https://omahaproxy.appspot.com/all.json",

        [Parameter(Mandatory = $False)]
        [ValidateSet('win', 'win64', 'mac', 'linux', 'ios', 'cros', 'android', 'webview')]
        [string[]] $Platform = @('win', 'win64', 'mac', 'linux', 'ios', 'cros', 'android', 'webview'),

        [Parameter(Mandatory = $False)]
        [ValidateSet('stable', 'beta', 'dev', 'canary', 'canary_asan')]
        [string[]] $Channel = @('stable', 'beta', 'dev', 'canary', 'canary_asan')
    )

    # Read the JSON and convert to a PowerShell object. Return the current release version of Chrome
    $chromeJson = (Invoke-WebRequest -uri $Uri).Content | ConvertFrom-Json
    
    # Read the JSON and build an array of platform, channel, version
    $table = @()
    ForEach ($os in $chromeJson) {
        ForEach ($version in $os.versions) {
            $item = New-Object PSCustomObject
            $item | Add-Member -Type NoteProperty -Name 'Platform' -Value $os.os
            $item | Add-Member -Type NoteProperty -Name 'Channel' -Value $version.channel
            $item | Add-Member -Type NoteProperty -Name 'Version' -Value $version.current_version
            $table += $item
        }
    }

    # Filter the output
    $output = $table | Where-Object { $Platform -contains $_.Platform } | `
        Where-Object { $Channel -contains $_.Channel }

    # Return output to the pipeline
    Write-Output $output
}
