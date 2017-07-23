param(
      [Alias("p")] [switch] $posts
    , [Alias("h")] [switch] $help)

if ($help.IsPresent)
{
    Write-Host "
	-help or -h --- View help
	"
	exit
}

$getHtmlPath = { [tuple]::Create($_, [io.path]::Combine($PSScriptRoot, "content", "post", ($_.Name.Substring($_.Name.LastIndexOf('-')+1)))) }
$notExistsOrNewer = { !(Test-Path $_.Item2) -or ((Get-ChildItem $_.Item2).LastWriteTime -le $_.Item1.LastWriteTime) }
function getDate {
    param ([string] $string)
    $string.Substring(0, $string.LastIndexOf('-'))
}

#if ($posts.IsPresent)
#{
    Get-ChildItem -Path .\src\post |
        ? { $_.Name -match "^\d{4}-\d{2}-\d{2}-.*$" } |
        % $getHtmlPath |
        #? $notExistsOrNewer |
        % {
            $date = getDate($_.Item1.Name)
            $content = Get-Content ([io.path]::Combine($PSScriptRoot, "src", "post",  $_.Item1))
            $content[0] += "`r`ndate: " + $date
            #$content[1] = "{0}`r`n{1}" -f "date: " + $date, $content[1]
            $content | Out-File $_.Item2 -Encoding utf8
        }
#}