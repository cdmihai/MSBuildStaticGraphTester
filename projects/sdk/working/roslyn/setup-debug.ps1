rm *binlog

rm -Force -Recurse -Path .\repo\ -Include "obj"
rm -Force -Recurse -Path .\repo\ -Include "bin"

.\repo\Restore.cmd

$m1 = Measure-Command{& $env:MSBuildBootstrapExe .\repo\Roslyn.sln /m /bl:bootstrap-sln.binlog /p:DeployExtension=false /p:CreateVsixContainer=false /clp:v=minimal | Out-Default}

rm -Force -Recurse -Path .\repo\ -Include "obj"
rm -Force -Recurse -Path .\repo\ -Include "bin"

.\repo\Restore.cmd

$m2 = Measure-Command{& $env:MSBuildBootstrapExe .\repo\Roslyn.proj /m /bl:bootstrap-proj.binlog /p:DeployExtension=false /p:CreateVsixContainer=false /clp:v=minimal | Out-Default}

rm -Force -Recurse -Path .\repo\ -Include "obj"
rm -Force -Recurse -Path .\repo\ -Include "bin"

.\repo\Restore.cmd

$m3 = Measure-Command{& $env:MSBuildBootstrapExe .\repo\Roslyn.proj /m /bl:bootstrap-proj-graph.binlog /graph /isolate /p:DeployExtension=false /p:CreateVsixContainer=false /clp:v=minimal | Out-Default}

Write-Host "bootstrap-sln $($m1.TotalSeconds)"
Write-Host "bootstrap-proj $($m2.TotalSeconds)"
Write-Host "bootstrap-proj-graph $($m3.TotalSeconds)"
