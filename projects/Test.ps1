param([string]$projectExtension)

$invocationDirectory=(pwd).Path
$msbuildBinaries="E:\projects\msbuild\artifacts\bin\bootstrap\net472\MSBuild\Current\Bin"
$msbuildApp="E:\projects\MSBuildTestProjects\src\msb\bin\Debug\net472\msb.exe"

function Combine([string]$root, [string]$subdirectory)
{
    return [System.IO.Path]::Combine($root, $subdirectory)
}

function BuildWithCacheRoundtripDefault([string] $projectRoot, [string] $projectFileExtension){

    BuildWithCacheRoundtrip "true" $projectRoot "$projectRoot\caches" $projectFileExtension
}

function BuildWithCacheRoundtrip([string] $useConsoleLogger, [string] $projectRoot, [string] $cacheRoot, [string] $projectFileExtension){
    & $msbuildapp $msbuildBinaries $useConsolelogger "-buildWithCacheRoundtrip" $projectRoot $cacheRoot $projectFileExtension
}

function BuildSingleProject($useConsoleLogger, $projectFile, $cacheRoot){
    # echo "$msbuildapp $msbuildBinaries -buildWithCacheRoundtrip $invokingScriptDirectory\caches $invokingScriptDirectory"

    & $msbuildapp $msbuildBinaries $useConsoleLogger "-singleProject" $projectFile $cacheRoot
}

function PrintHeader([string]$text)
{
    $line = "=========================$text========================="
    Write-Output ("=" * $line.Length)
    Write-Output $line
    Write-Output ("=" * $line.Length)
}

function SetupTestProject([string]$projectRoot)
{
    Remove-Item -Force -Recurse "$projectRoot\**\bin"
    Remove-Item -Force -Recurse "$projectRoot\**\obj"

    $setupScript = Combine $projectRoot "setup.ps1"

    if (Test-Path $setupScript)
    {
        & $setupScript
    }
}

if ($projectExtension) {
    PrintHeader $invocationDirectory
    SetupTestProject $invocationDirectory
    BuildWithCacheRoundtripDefault "$invocationDirectory" $projectExtension
    exit
}

$workingProjectRoots = @{
    "$PSScriptRoot\non-sdk\working" = "proj";
    "$PSScriptRoot\sdk\working" = "csproj"
}

$brokenProjects = @("oldWPF1", "oldWPF-new-2")

foreach ($directoryWithProjects in $workingProjectRoots.Keys)
{
    $projectExtension = $workingProjectRoots[$directoryWithProjects]

    foreach ($projectRoot in Get-ChildItem -Directory $directoryWithProjects)
    {
        if ($brokenProjects.Contains($projectRoot.Name))
        {
            PrintHeader "Skipping $($projectRoot.FullName)"
            continue;
        }

        PrintHeader $projectRoot.FullName
        SetupTestProject $projectRoot.FullName
        BuildWithCacheRoundtripDefault $projectRoot.FullName $projectExtension

        if ($LASTEXITCODE -ne 0)
        {
            exit
        }
    }
}