# Scorch

## Introduction

The main goal of the Sista VM is to add adaptive optimisations such as speculative inlining in Cog’s JIT compiler using type information present in the inline caches. Such optimisations both improve Cog’s performance and allow developers to write easy-to-read code over fast-to-execute code without performance overhead (typically, #do: is the same performance as #to:do:).

Scorch is the adaptive optimizer written in Smalltalk, it is compatible with the VM from opensmalltalk-vm.

## Status: Open alpha release

Link: https://clementbera.wordpress.com/2017/07/19/sista-open-alpha-release/

As all alpha releases, it is reserved for VM developers (the release is not relevant for non VM developers, and clearly no one should deploy any application on it yet). Last year we had a closed apha release with a couple people involved such as Tim Felgentreff who added support for the Sista VM builds in the Squeak speed center after tuning the optimisation settings.

## Past activity

This repository has been moved from Smalltalk-hub to github March 13th 2018.

For all the activity in-between Jun 2016-March 2018, check http://smalltalkhub.com/#!/~ClementBera/Scorch

For all the activity in-between May 2013-Jun 2016, check http://smalltalkhub.com/#!/~mate/sista

I was not involved in the project before May 2013 so I have no idea where activity before May 2013 is.

## Using the Sista runtime

Loading scripts:

```bash
wget -O- get.pharo.org/61+vm | bash
./pharo-ui Pharo.image
```

```Smalltalk
Metacello new
        githubUser: 'clementbera' project: 'Scorch' commitish: 'master' path: 'repository';
        baseline: 'Scorch';
        onWarningLog;
        load	
```

Notes:

Use a sista enabled VM 
- Check squeak.sista.spur & pharo.sista.spur builds on opensmalltalk-vm
- pick a VM here: http://files.pharo.org/vm/sista

The most stable image version is currently Pharo 6.1

After loading the configuration in your image, workspaces will appear with explanation on what you can do (Similar to VMMaker workspaces)

## Repository organization

- repository includes Scorch's Smalltalk code
- spec includes the specification of unsafe operations in JSON format with a class to ease parsing.

- Master is release branch
- Development is my branch