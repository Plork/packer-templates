# packer-templates
A Packer template that simplifies the creation of minimally-sized Windows Vagrant boxes.

## Prerequisites

You need the following to run the template:

1. [Packer](https://packer.io/docs/installation.html) installed with a minimum version of 0.8.6.
2. [VirtualBox](https://www.virtualbox.org/wiki/Downloads)

## Invoking the template
Invoke `packer` to run the template like this:
```
packer build -force -only virtualbox-iso .\vbox-2012r2.json
```

## Converting to Hyper-V
This repo includes PowerShell scripts that can create a Hyper-V Vagrant box from the output VirtualBox .vmdk file. This repo leverages [psake](https://github.com/psake/psake) and [Chocolatey](https://chocolatey.org) to ensure that all prerequisites are installed and then runs the above `packer` command followed by the scripts needed to produce a Vagrant .box file that can create a Hyper-V file.
