---
title: Managing multiple solutions
date: 2025-03-27
description: >
  Managing multiple solutions for a customer can be a pain, when needing
  to navigate or repeatedly switch between them.  This blog documents a powershell script to help make that process easier.
categories:
  - Development
  - Powershell
  - 'Visual Studio'
# links:
#   - setup/setting-up-a-blog.md
#   - plugins/blog.md
draft: false
---
# Managing Multiple Solutions

Do you find that when you are working you need to manage multiple solutions and continually have to switch between them?  I find I'm having to do this 
for every customer where I have to juggle over 10 solutions, often in their
own repositories, for the different aspects of the wider product.

As I spend most of my time in Powershell I created a Powershell menu based
system to navigate between these solutions easily, and assign the correct Azure and DevOps context on startup.

## Directory structure

In order to simplify the management I put all the solutions for a customer in their own directory/folder structure.

```text
<sourceRoot>
  |- Customer 1
  |   |- project 1
  |   |- project 2
  |   |- project 3
  |   |- solution.json
  |   |- customer.ps1
  |
  |- Customer 2
      |- project 1
      |- project 2
      |- project 3
      |- solution.json
      |- customer.ps1
```

You can see there is a `solution.json` for each customer, this file is detailed below, but contains the projects that I'm wanting to show on the menu.  As I tend to keep the key ones I use on the menu, rather than the ones I don't touch often.

There is also a Powershell file for each customer.  This is to handle the uniqueness of the environment setup.  Root directory for the customer etc.  Lets look individually at these.

### The Menu definition: solution.json

A sample solution file is below.  This sample produces three menu items:

```json
[
  {
    "PathName": "Root",
    "PathFullName": "C:\\Src\\Customer1\\",
    "Name": "",
    "FullName": ":Exit:"
  },
  {
    "PathName": "Docs and API Samples",
    "PathFullName": "C:\\Src\\Customer1\\Docs",
    "Name": "",
    "FullName": "::."
  },
  {
    "PathName": "Code Gen",
    "PathFullName": "C:\\Src\\Customer1\\project1",
    "Name": "Project1.sln",
    "FullName": "C:\\Src\\Customer1\\project1\\Project1.sln"
  }
]
```

`Root`

: This Entry is always the first. The path is to the customers root.  This enables a quick option for getting to the customer's source folder.  This will be discussed later.  The `:Exit:` indicates to the open solution routines that this option doesn't need to do anything.

`Docs and API Sample`

: This entry is a `VS Code` solution as indicated by the full name starting with `::` the remainder of the fullname is passed to VS Code as what I would normally type... i.e. in this case `code .` which is my shortcut for opening a `VS Code` workspace from the current folder.

: For this type of entry, VS Code's working directory is set to the Path FullName before execution.

`Code Gen`

: This entry is a sample of a standard project entry to open a VS Solution.  The way this works is to execute `start` before whatever the fullname is.  i.e. in this case `start C:\Src\Customer1\project1\Project1.sln`

## The Script

This is the main powershell file.  It starts with a set of self explanatory variables:

```powershell
$PAT = "--Azure Devops PAT key--"
$Organisation = "--Azure DevOps Organisation--"
$Project = "--Azure DevOps Project--"
$trunkBranch = "dev"       #the trunk branch used by the customer... typically Main or Master
$froot="c:\src\Customer1"  #Customer's project folder.
```

Then it moves onto some function definitions:

`MakeSelection` and `GetSln` manage the menu functionality.

`Fetch-DCGitSolutions` : This navigates all folders under the customer root (`$froot`) to find all `.git` folders and if one exists runs `git fetch; git pull` in that folder.  This provides a single command to pull all the repos for the customer.

`Switch-DCGitSolutions` : This switches all the repo branches to `$trunkBranch`.

`Open-DCSolution` : Opens the solution from the menu.

`Set-DCSolution` : Change to the directory from the menu.

Once those are defined.  The script then loads the VSTeam module, sets the VSTeam context using the PAT token.  

Sets some alias shortcuts: 

```powershell
Set-Alias ccd Set-DCSolution
Set-Alias cop Open-DCSolution
Set-Alias switchall Switch-DCGitSolutions
Set-Alias fetchall Fetch-DCGitSolutions
```

It ends with Displaying the menu for reference.
```powershell
Write-Host -ForegroundColor Yellow "Solution list:"
$menu = ConvertFrom-JSON (Get-Content $froot/solutions.json -Raw)
$i = 0;
$menu |ForEach-Object {
   $opt = $i++
   $o = $_.PathName
   Write-Host -foregroundcolor cyan -nonewline ("`t{0}. " -f $opt)
   Write-Host -foregroundcolor white "`t$o"
}
```

!!! Note

    The full script is available for download from [customer.ps1](../../../../assets/code/2025-03/customer.ps1)


## Loading in terminal

The power of this script comes when you create a shell for the customer, i.e. this script loads on startup.  So to do this in the Terminal app go to the settings and create a profile for it.

Create the profile and set the command line to:
```cmd
"C:\Program Files\PowerShell\7\pwsh.exe" -NoExit -c . ./customer.ps1
```

Set the starting directory to the customer directory (i.e. the location of the customer.ps1 file.)

Set anything else you want, i.e. icon, tab colour, etc.

##  Executing...

Now that you have all of that, when loaded into your "Customer Shell" you have the following options available to you:

### Variables (not in the enviroment)
```Powershell
$PAT
```
This is your PAT key, useful if you are attempting to call the DevOps APIs or run VSTeam powershell commands.

### CCD
```Powershell
ccd <number>
```
Short for _Customer Change Directory_ this will change the current working directory to that folder that numbered solution.  If you don't specify a number then a menu is displayed for you to select from.  Note the menu also shows you what Git branch that solution is currently in.

### COP
```Powershell
cop <number>
```
Short for _Customer OPen_ this will open the solution you specify.  As for `ccd` if you don't specify a number then the menu is displayed.

### Git Helpers
```Powershell
switchall
fetchall
```
`switchall` and `fetchall` perform `git switch` and `git fetch;git pull` actions on all the folders from the customer's root.

## Conculsion
I built this solution because I spend the majority of my time in a Powershell console window and need to navigate between multiple solutions for a customer.  This is my solution to help simplify the commands I repeat all the time.

Feel free to customise this solution to your needs, it is a simple powershell script after all.
