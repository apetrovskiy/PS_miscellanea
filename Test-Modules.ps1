ipmo C:\Projects\PS\STUPS\UIA\UIAutomation\bin\Release\UIAutomation.dll;
ipmo C:\Projects\PS\STUPS\TMX\TMX\bin\Release\TMX.dll;
ipmo C:\Projects\PS\STUPS\TAMS\TAMS\bin\Release\TAMS.dll;
ipmo C:\Projects\PS\STUPS\TestUtils\bin\Release\TestUtils.dll;
ipmo C:\Projects\NW\NMC\testConfigurator\NwxAutomation.Cmdlets\bin\Release\NwxAutomation.Cmdlets.dll;

$global:TestHome = "C:\TestHome";
Get-ChildItem C:\Projects\NW\PSModules | `
	?{ 'bin' -ne $_.Name -and 'obj' -ne $_.Name -and (-not $_.Name.Contains(".")) -and 'SelfTest' -ne $_.Name } | `
	%{ try { Write-Host "loading module $($_.Name)"; ipmo $_.FullName; gmo $_.Name; } catch { Write-Host "failed to load the $($_.Name) module!"; $Error[0].CategoryInfo; if ('ParserError' -eq $Error[0].CategoryInfo) { "aaaaa!"; } } }

function Test-PowerShellSyntax
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string[]]
        $Path
    )

    process
    {
        foreach ($scriptPath in $Path) {
            $contents = Get-Content -Path $scriptPath

            if ($null -eq $contents)
            {
                continue
            }

            $errors = $null
            $null = [System.Management.Automation.PSParser]::Tokenize($contents, [ref]$errors)

            if (0 -lt $errors.Count) {
                New-Object psobject -Property @{
                    Path = $scriptPath
                    SyntaxErrorsFound = ($errors.Count -gt 0)
                }
            }
        }
    }
}

Get-ChildItem C:\Projects\NW\*.ps1 -Recurse | Test-PowerShellSyntax
Get-ChildItem C:\Projects\NW\*.psm1 -Recurse | Test-PowerShellSyntax

function Test-Xml
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string[]]
        $Path
    )

    process
    {
        foreach ($xmlPath in $Path) {
            try {
                $xml = [xml](Get-Content -Path $xmlPath)
            }
            catch {
                Write-Host "failed to load XML file $($xmlPath)";
            }
        }
    }
}

Get-ChildItem C:\Projects\NW\*.xml* -Recurse | Test-Xml
