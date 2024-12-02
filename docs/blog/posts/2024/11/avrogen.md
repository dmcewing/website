---
title: Avro to C# model classes
date: 2024-11-18
description: >
  
categories:
  - Development
  - C-Sharp
  - Avro
  - Kafka
# links:
#   - setup/setting-up-a-blog.md
#   - plugins/blog.md
draft: true
---
# Avro to C# model classes

When delaing with Kafka Avro messages and you want to use the `ISpecificRecord` interface so you can early bind
your model in.  The model classes provide the models for deserialising/seralising the Kafka messages.  These model 
classes are automatically generated from JSON looking Schemas.

There are a number of tools available to do this but I have used the following tools:
1. AvroGen - https://bartwullems.blogspot.com/2020/11/kafka-using-avro-as-serialization.html
1. [Microsoft-Avro](https://github.com/dougmsft/microsoft-avro)

The first step is to get the Avro model as an AVSC file.  This can be downloaded directly from the topic in confluent
cloud or using the schema registry APIs to get a copy.

## Using Avrogen

The `avrogen` tool needs to be installed first with...
```PS
dotnet tool install --global Apache.Avro.Tools --version 1.11.3
```

Once installed the following can be called to generate the model classes...
```PS
avrogen -s ./schema-sampleavro-value-v1.avsc "sampleavro" --skip-directories 
```

### Automating the generation

It became quite painful on a recent project with all the updates that kept on being made to these schemas.  So I 
automated this using PowerShell with this script, which searches for and generates the schema for all `*.avsc` files 
in the folder reading the namespace from inside the Avro schema.

```PS
Write-Host -ForegroundColor darkCyan "Removing existing classes..."
Remove-Item -Recurse .\tahiContractDomain\ -Force
Remove-Item -Recurse .\tahiPartyDomain\ -Force

Write-Host -ForegroundColor darkCyan "Generating new classes..."

$domainNames = @()

$avroFiles = Get-ChildItem "*v?*.avsc"
$avroFiles |% {
    Write-Host -ForegroundColor darkYellow $_.Name "..."
    $avro = ConvertFrom-Json (Get-Content $_.FullName -raw)
    $avroName = $avro.name
    $connectName = $avro.'namespace'
    $domainName = $connectName.split('.')[-1]
    
    avrogen -s $_.FullName $domainName --skip-directories 
}
```

## Avro Namespace

The _avrogen_ tool contains an option to change the namespace of the outputted C# classes.  However, the namepace change
is not updated in the schema string that is coded into the classes, so if you use that feature it is very likely that the
Avro serializer/deserializer classes will not work.  This is because the namespace inside in the schema string is used to
dynamically retrieve and instantiate the model class.

I had some thoughts about using a namespace resolver to translate, however, it is not possible to inject this into the Avro
Serializer/Deserializer famework classes.  I aslo tried manually adjusting the schema strings, but deemed that too much effort 
at the time.

