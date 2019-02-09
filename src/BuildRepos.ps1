param (
    [switch]$BuildSdk,
    [switch]$BuildMSBuild,
    [switch]$DogfoodSdk,
    [string]$Repos = [System.IO.Path]::Combine($PSScriptRoot, "rps"),
    [string]$MSBuildBranch = "graphCrossTargetting",
    [string]$MSBuildRepoAddress = "https://github.com/cdmihai/msbuild.git",
    [string]$SDKBranch = "master",
    [string]$SDKRepoAddress = "https://github.com/dotnet/sdk.git",
    [string]$Configuration = "Release"
)

function Combine([string]$root, [string]$subdirectory)
{
    return [System.IO.Path]::Combine($root, $subdirectory)
}

function CloneRepoIfNecessary([string]$address, [string] $branch, [string] $repoPath)
{
    if (Test-Path  $repoPath) {
        return
    }

    & git clone $address $repoPath

    Push-Location $repoPath

    & git checkout $branch

    Pop-Location
}

function BuildMSBuildRepo([string]$MSBuildRepo)
{
    & "$MSBuildRepo\eng\common\build.ps1" -build -restore -ci -pack -configuration $Configuration /p:CreateBootstrap=true /p:ApplyPartialNgenOptimization=false
    # & "$MSBuildRepo\eng\common\build.ps1" -build -restore -configuration $Configuration /p:CreateBootstrap=true
    # & "$MSBuildRepo\eng\common\build.ps1" -ci -pack -configuration $Configuration /p:ApplyPartialNgenOptimization=false
}

function BuildSdkRepo([string]$SdkRepo)
{
    & "$SdkRepo\eng\common\build.ps1" -build -restore -configuration $Configuration
}

function DogfoodSdk([string]$SdkRepo)
{
    & "$SdkRepo\eng\dogfood.ps1" -configuration $Configuration
}

function GetNugetVersionFromFirstFileName([string] $nugetPackageRoot)
{
    $nugetPackage = Get-ChildItem $nugetPackageRoot | Select-Object -First 1

    return GetNugetVersion $nugetPackage.FullName
}

function GetNugetVersion([string] $nugetPackageFile)
{
    $versionStart = $nugetPackageFile.IndexOf("16.0.0")
    $versionEnd = $nugetPackageFile.IndexOf(".nupkg")

    $version = $nugetPackageFile.SubString($versionStart, $versionEnd - $versionStart)

    return $version
}

function RemoveItemIfExists([string] $item)
{
    if (Test-Path $item)
    {
        Remove-Item $item
    }
}

function ResetEnvironment()
{
    $env:DOTNET_INSTALL_DIR = ""
    $env:DOTNET_MULTILEVEL_LOOKUP = ""
    $env:SDK_REPO_ROOT = ""
    $env:SDK_CLI_VERSION = ""
    $env:MSBuildSDKsPath = ""
    $env:DOTNET_MSBUILD_SDK_RESOLVER_SDKS_DIR = ""
    $env:NETCoreSdkBundledVersionsProps = ""
    $env:MicrosoftNETBuildExtensionsTargets = ""

    RemoveItemIfExists "Variable:_DotNetInstallDir"
    RemoveItemIfExists "Variable:_ToolsetBuildProj"
    RemoveItemIfExists "Variable:_BuildTool"
}

if ($BuildMSBuild)
{
    ResetEnvironment

    $MSBuildRepo = Combine $Repos "MSBuild"

    CloneRepoIfNecessary $MSBuildRepoAddress $MSBuildBranch $MSBuildRepo
    BuildMSBuildRepo $MSBuildRepo

    $env:MSBuildBootstrapDirectory = "$msbuildRepo\artifacts\bin\bootstrap\net472\MSBuild\Current\Bin"
    $env:MSBuildNugetPackages = "$msbuildRepo\artifacts\packages\$Configuration\Shipping"
    $env:MSBuildNugetVersion = GetNugetVersionFromFirstFileName $env:MSBuildNugetPackages
}

$SdkRepo = Combine $Repos "sdk"

if ($BuildSdk)
{
    ResetEnvironment

    CloneRepoIfNecessary $SDKRepoAddress $SDKBranch $SdkRepo
    BuildSdkRepo $SdkRepo
}

if ($DogfoodSdk)
{
    ResetEnvironment

    DogfoodSdk $SdkRepo
}