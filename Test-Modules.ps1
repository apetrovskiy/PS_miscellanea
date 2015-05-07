[string]$binModulesPath = "C:\Projects\PS\STUPS";
[string]$psModulesPath = "C:\Projects\NW";
$global:TestHome = "C:\TestHome";

ipmo "$($binModulesPath)\UIA\UIAutomation\bin\Release\UIAutomation.dll";
ipmo "$($binModulesPath)\TMX\TMX\bin\Release\TMX.dll";
ipmo "$($binModulesPath)\TAMS\TAMS\bin\Release\TAMS.dll";
ipmo "$($binModulesPath)\TestUtils\bin\Release\TestUtils.dll";
ipmo "$($psModulesPath)\NMC\testConfigurator\NwxAutomation.Cmdlets\bin\Release\NwxAutomation.Cmdlets.dll";

Get-ChildItem "$($psModulesPath)\PSModules" | `
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

Get-ChildItem "$($psModulesPath)\*.ps1" -Recurse | Test-PowerShellSyntax
Get-ChildItem "$($psModulesPath)\*.psm1" -Recurse | Test-PowerShellSyntax

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

Get-ChildItem "$($psModulesPath)\*.xml*" -Recurse | Test-Xml
