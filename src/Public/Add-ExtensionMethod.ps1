function Add-ExtensionMethod {
    [CmdletBinding()]
    param(
        # Specifies a path to one or more locations.
        [Parameter(Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'Path to assembly to process.')]
        [Alias('PSPath')]
        [Alias('Path')]
        [ValidateNotNullOrEmpty()]
        [string]
        $DllPath
    )

    Process {
        $assembly = [System.Reflection.Assembly]::LoadFrom($DllPath)
        $types = $assembly.GetExportedTypes()

        $extensionMethods = @()

        foreach($type in $types)
        {
            if($type.IsSealed -and $type.IsAbstract)
            {
                $methods = $type.GetMethods() | Where-Object { $_.IsStatic } | Where-Object { -not $_.IsGenericMethod }
                foreach($method in $methods)
                {
                    if([System.Runtime.CompilerServices.ExtensionAttribute]::IsDefined($method, [System.Runtime.CompilerServices.ExtensionAttribute]))
                    {
                        $parameters = $method.GetParameters()
                        # simple extension methods first
                        if ($parameters.Count -eq 1) {
                            $extensionMethods += $method
                        }
                    }
                }
            }
        }

        $extensionMethods | ForEach-Object {
            $targetType = $_.GetParameters()[0].ParameterType
            $methodName = $_.Name

            Write-Debug "Found: TypeName: $targetType, MemberName: $methodName"

            $command = @"
[OutputType([$($_.ReturnType)])]
param()
[$($_.DeclaringType)]::$methodName(`$this)
"@

            $scriptblock = [Scriptblock]::Create($command)

            Write-Debug "--- Generated Command ---"
            Write-Debug $command
            Write-Debug "-------------------------"

            Update-TypeData -TypeName $targetType -MemberType ScriptProperty -MemberName $methodName -Value $scriptblock
        }
    }
}
