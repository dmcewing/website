$PAT = "--Azure Devops PAT key--"
$Organisation = "--Azure DevOps Organisation--"
$Project = "--Azure DevOps Project--"
$trunkBranch = "dev"
$froot="c:\src\Customer1"  #Customer's project folder.

function MakeSelection($message, $minChoice, $maxChoice) {
    $validOption = $true;
    do{
        $choice = read-host "$message ($minChoice - $maxChoice)"
        $op = $null;

        if (![int]::TryParse($choice, [ref]$op))
        {
            Write-Host -foregroundcolor red "$choice : Invalid option, please enter a number!"
            $validOption = $false;
        }
        else{
            if (($op -lt $minChoice) -or ($op -gt $maxChoice))
            {
                Write-Host -foregroundcolor red "$op : Invalid option, please enter a number between $minChoice and $maxChoice!"
                $validOption = $false;
            }
            else{
                Write-Host "$choice selected."
                return $choice;
            }
        }
    }while(!$validOption)
}

function GetSln($id, $message){
    $menu = ConvertFrom-JSON (Get-Content $froot/solutions.json -Raw)

    if ($id -ge 0)
    {
       return $menu[$id];	
    }
    else
    {		
        Write-Host "";
        Write-Host -foreground yellow $message
        $i = 0;
        $menu |% {
            $opt = $i++
            $o = $_.PathName
            Write-Host -foregroundcolor cyan -nonewline ("`t{0,4}. " -f $opt)
            Write-Host -foregroundcolor white -nonewline ("{0,-25}" -f $o)
            $head = GetHead($_.PathFullName)
            Write-Host -foregroundcolor yellow "[$head]"
        }
    
        $action = MakeSelection "Please select" 0 ($menu.Length - 1)
        return $menu[$action];
    }
}

function GetHead($path) {
    if (Test-Path -Path $path/.git)
    {
           return (Get-Content $path/.git/HEAD).Replace("ref: refs/heads/","")
    }
    return ""
}


function Set-DCSolution {
<#
.SYNOPSIS
    Changes to a directory for a solution defined in the solution.json file.
.DESCRIPTION
    If no parameter is supplied then a menu is displayed instead.
.PARAMETER id
    The id of the solution to change to.
#>

    #region Parameter
    [CmdletBinding(ConfirmImpact='None')]
    Param(
        [Parameter(Position = 0)]
        [int] $id = -1
    )
    #endregion Parameter

    Set-Location (GetSln $id "Where do you want to go?").PathFullName
}

function Open-DCSolution {
<#
.SYNOPSIS
    Changes to a directory for a solution defined in the solution.json file.
.DESCRIPTION
    If no parameter is supplied then a menu is displayed instead.
.PARAMETER id
    The id of the solution to change to.
#>

    #region Parameter
    [CmdletBinding(ConfirmImpact='None')]
    Param(
        [Parameter(Position = 0)]
        [int] $id = -1
    )
    #endregion Parameter
    $sln = (GetSln $id "What solution do you want to use?") 
    if ($sln.Fullname -eq ":Exit:")
    {
        Write-Host "Exiting menu."
    }
	elseif ($sln.FullName.startswith("::"))
	{
		$p = $sln.PathFullName
		$a1 = $sln.FullName.substring(2)
		Start-Process -FilePath "$env:LOCALAPPDATA\\Programs\\Microsoft VS Code\\code.exe" -ArgumentList $a1 -WorkingDirectory $p -UseNewEnvironment -redirectStandardOutput nul
	}
	else {
		Start-Process $sln.FullName
	}
    
}

function Fetch-DCGitSolutions()
{
   Push-Location
   Set-Location $froot
   $git = (Get-ChildItem -recurse .git -Depth 4 -Directory -Hidden)

   $max = $git.length * 2
   $count = 0;

   $git |ForEach-Object {
      $count++;
      $p = $_.Parent.Name;
	Write-Host -foreground green $p

      $per = ($count/$max * 100);
      $label = "Fetching... {1:N0}%" -f $p, $per
      Write-Progress -Activity $p -Status $label -PercentComplete $per
      
      Push-Location
      Set-Location $_.Parent
      git fetch

      $count++;
      $per = ($count/$max * 100);
      $label = "Pulling... {1:N0}%" -f $p, $per
      Write-Progress -Activity $p -Status $label -PercentComplete $per
      git pull
      Pop-Location      

      Write-Host -foreground yellow $p

   }
   Pop-Location
}

function Switch-DCGitSolutions()
{
    Push-Location
    Set-Location $froot
    $git = (Get-ChildItem -recurse .git -Depth 4 -Directory -Hidden)

    $git |ForEach-Object {
        $branch = (Get-Content $_/HEAD).Replace("ref: refs/heads/","")
        if ($branch -ne $trunkBranch -and -not ($_.Parent.Name.Contains("wiki")))
        {
            Write-Host -NoNewline -ForegroundColor yellow ("{0,-35}" -f $_.Parent.Name)

            $p = $_.Parent.Name;

            Push-Location
            Set-Location $_.Parent
            git switch $trunkBranch
    
            Pop-Location
            Write-Host -foreground yellow $p

        }
    }
    Pop-Location
}

function ConvertFrom-Base64 {
<#
.SYNOPSIS
    Convert from a Base64 string to normal string
.DESCRIPTION
    Convert from a Base64 string to normal string. Function aliased to 'Base64Decode'.
.PARAMETER Base64
    A base64 encoded string
.PARAMETER IncludeInput
    Switch to enable including the input to appear in the output
.EXAMPLE
    ConvertFrom-Base64 "SABlAGwAbABvAA=="
 
    Would return
    Hello
.EXAMPLE
    ConvertFrom-Base64 "SABlAGwAbABvAA==" -IncludeInput
 
    Would return
    Base64 String
    ------ ------
    SABlAGwAbABvAA== Hello
.OUTPUTS
    [string[]]
#>

    #region Parameter
    [CmdletBinding(ConfirmImpact='None')]
    Param(
        [Parameter(Position = 0, Mandatory, ValueFromPipeLine)]
        [string[]] $Base64,

        [switch] $IncludeInput
    )
    #endregion Parameter

    begin {
        Write-Verbose -Message "Starting [$($MyInvocation.Mycommand)]"
    } #close begin block

    process {
        foreach ($curBase64 in $Base64) {
            $bytesfrom = [Convert]::FromBase64String($curBase64)
            $decodedfrom = [Text.Encoding]::ASCII.GetString($bytesfrom)
            if ($IncludeInput) {
                New-Object -TypeName psobject -Property ([ordered] @{
                    Base64 = $curBase64
                    String = $decodedfrom
                })
            } else {
                Write-Output -InputObject $decodedfrom
            }
        }
    }

    end {
        Write-Verbose -Message "Ending [$($MyInvocation.Mycommand)]"
    }

}

#Set-Alias -Name 'Base64Decode' -Value 'ConvertFrom-Base64' -Description 'Alias for ConvertFrom-Base64'

Write-Host -ForegroundColor gray -NoNewLine "Loading VSTeam Module..."
import-module VSTeam
Write-Host -ForegroundColor green "[OK]"

Write-Host -ForegroundColor gray -NoNewLine "Setting Azure DevOps defaults..."
Set-VSTeamAccount -PersonalAccessToken $pat -Account https://dev.azure.com/kotahi
Set-VsTeamDefaultProject -Project $project
Write-Host -ForegroundColor green "[OK]"

Write-Host -ForegroundColor gray -NoNewLine "Setting Aliases..."

Set-Alias ccd Set-DCSolution
Set-Alias cop Open-DCSolution
Set-Alias switchall Switch-DCGitSolutions
Set-Alias fetchall Fetch-DCGitSolutions

Write-Host -ForegroundColor green "[OK]"

Write-Host -ForegroundColor Yellow "Solution list:"
$menu = ConvertFrom-JSON (Get-Content $froot/solutions.json -Raw)
$i = 0;
$menu |ForEach-Object {
   $opt = $i++
   $o = $_.PathName
   Write-Host -foregroundcolor cyan -nonewline ("`t{0}. " -f $opt)
   Write-Host -foregroundcolor white "`t$o"
}

Write-Host "";
