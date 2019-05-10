# setup repos
& "$PSScriptRoot/Build.ps1" -BuildRepos

# sdk style wpf, it works
& "$PSScriptRoot/Test.ps1" -singleProjectDirectory "$PSScriptRoot\..\projects\sdk\working\newWPF1\"

# old style wpf, fails in MarkupCompilePass1
& "$PSScriptRoot/Test.ps1" -singleProjectDirectory "$PSScriptRoot\..\projects\sdk\working\oldWPF1"