$ErrorActionPreference = "Stop"
Set-StrictMode -Version "Latest"

# $env:MSBuildDebugOnStart="1"

delDirs bin obj

dotnet restore nuget-pack.sln

dotnet msbuild .\root-new-single\root-new-single.csproj /bl:vanilla.binlog /p:DisableTransitiveProjectReferences=true

sf *nupkg | rm

E:\projects\msbuild\artifacts\bin\bootstrap\net472\MSBuild\Current\Bin\MSBuild.exe /graph /isolate /bl:graph.binlog /m:1 /p:BuildProjectReferences=false .\root-new-single\root-new-single.csproj

$env:MSBuildDebugOnStart=""