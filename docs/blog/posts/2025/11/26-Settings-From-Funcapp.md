---
date: 2025-11-26
description: >

categories:
  - Development
  - Azure 
# links:
#   - setup/setting-up-a-blog.md
#   - plugins/blog.md
draft: false
---
# Copying settings from a running Azure FuncApp

!!! note "Reference"
    This post taken as a quicker reference from [Will Velida's post](https://hackernoon.com/how-to-use-azure-functions-core-tools-to-create-a-localsettingsjson-file-and-run-functions-locally)

## 1. Ensure the Azure CLI is signed in

```powershell
az login
```

and check the subscription (now part of the login step)

```powershell
az account set -s "<subscription-name-or-id>"
```

## 2. Copy settings

Ensure you are in the projects directory and run...

```powershell
func azure functionapp fetch-app-settings '<function-name>' --output-file local.settings.json
```

Settings are downloaded and encrypted so...

## 3. Decrypt them

```powershell
func settings decrypt
```

## 4. Pretty Format

The default settings from Azure use a dotted notation rather than nesting the JSON.  Either is useable, but I prefer the nice nested structure.  The following Powershell will convert the output to nested format.

```powershell
#Load the local.settings.json into an object...
$c = Get-Content .\local.settings.json -raw
$c = ConvertFrom-Json $c

#Get the values collection.
$values = $c.Values;
#and the name of each value...
$props = $values | Get-Member |Where-Object {$_.MemberType -eq 'NoteProperty'}

#Now for each value name
$props | ForEach-Object {
    $pName = $_.Name;

    #Only process if it contains a delimiter
    if ($pName.Contains(':'))
    {
        #Get the value of the property...
        $value = ($values.($pName))
        #Remove the property from values...
        $values.PSObject.Properties.Remove($pName)

        #Split the nodes out...
        $x = $pName.Split(":")
        $component = $x[$x.Length-1];

        $o = $c #Start with the root, and then progressively add each component of the delimited string...
        0..($x.Length -2) | ForEach-Object {
            $testV = $o.($x[$_])   #  $_ = 0 through length-2 of the $x array.  $x[$_] is therefore the component name and $o.($x[$_]) is the value of it (based on $o)
            if ($testV -eq $null)  # Wasn't found...
            {
                #So we need to add that component...
                $o |Add-Member -NotePropertyName $x[$_] -NotePropertyValue (new-object PSObject)
            }
            #Otherwise, and once added.... give it a value.
            $o = $o.($x[$_])
        }
        #Now assign the value to the new object.
        $o | Add-Member -NotePropertyName $component -NotePropertyValue $value
    }
}

#Now save the modified config out...
ConvertTo-Json $c -Depth 10 | Set-Content .\local.settings.json

```

