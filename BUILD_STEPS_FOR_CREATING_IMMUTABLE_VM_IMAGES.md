# Build Steps for Creating the Platform VM Images

# AppD Cloud Platform

The AppDynamics Cloud Platform is a DevOps project to help automate the deployment of an HA configuration
of the AppDynamics Platform in the cloud. It consists of a code repository with Infrastructure as Code (IaC)
artifacts, software provisioning modules, and a runbook with step-by-step instructions for deploying the
platform.

It is based on the concepts of Immutable Infrastructure and Idempotent provisioning.

## Overview

The AppDynamics Cloud Platform project enables an IT Administrator, Software Developer, or DevOps engineer to
automate the building of immutable VM images using open source tools from [HashiCorp](https://www.hashicorp.com/).
Currently, the VMs consist of these types:

-	__AppD-Cloud-Platform VM__: An APM Platform stand-alone VM designed for Application Performance Monitoring. It consists of the AppDynamics Enterprise Console, Controller, and Events Service.
-	__CWOM-Platform VM__: A Cisco Workload Optimization Manager (CWOM) stand-alone VM designed for Intelligent Workload Management. It consists of the CWOM Platform server.
-	__LPAD VM__: An AWS EC2 'Launchpad' VM with pre-configured tooling for Kubernetes and Serverless CLI Operations.

## Installation Instructions - macOS

To build the AppD Cloud Platform VM images, the following open source software needs to be installed on the host macOS machine:

-	Homebrew 4.2.12
	-	Command Line Tools (CLT) for Xcode
-	Packer 1.10.2
-	Git 2.44.0
-	jq 1.7.1

Perform the following steps to install the needed software:

1.	Install [Command Line Tools (CLT) for Xcode](https://developer.apple.com/downloads).  
    `$ xcode-select --install`  

    **NOTE:** Most Homebrew formulae require a compiler. A handful require a full Xcode installation. You can install [Xcode](https://itunes.apple.com/us/app/xcode/id497799835), the [CLT](https://developer.apple.com/downloads), or both; Homebrew supports all three configurations. Downloading Xcode may require an Apple Developer account on older versions of Mac OS X. Sign up for free [here](https://developer.apple.com/register/index.action).  

2.	Install the [Homebrew 4.2.12](https://brew.sh/) package manager for macOS 64-bit. Paste the following into a macOS Terminal prompt:  
    `$ /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"`

3.	Install [Packer 1.10.2](https://packer.io/) for macOS 64-bit.  
    `$ brew install packer`  

4.	Install [Git 2.44.0](https://git-scm.com/downloads) for macOS 64-bit.  
    `$ brew install git`  

5.	Install [jq 1.7.1](https://jqlang.github.io/jq/) for macOS 64-bit.  
    `$ brew install jq`  

### Configuration and Validation - macOS

1.	Validate installed command-line tools:

    ```bash
    $ brew --version
    Homebrew 4.2.12
    $ brew doctor
    Your system is ready to brew.

    $ packer --version
    1.10.2

    $ git --version
    git version 2.44.0

    $ jq --version
    jq-1.7.1
    ```

2.	Configure Git for local user:

    ```bash
    $ git config --global user.name "<your_name>"
    $ git config --global user.email "<your_email>"
    $ git config --global --list
    ```

## Installation Instructions - Windows 64-Bit

To build the AppD Cloud Platform immutable VM images, the following open source software needs to be installed on the host Windows machine:

-	Packer 1.10.2
-	Git 2.44.0 for Win64
-	jq 1.7.1

Perform the following steps to install the needed software:

1.	Install [Packer 1.10.2](https://releases.hashicorp.com/packer/1.10.2/packer_1.10.2_windows_amd64.zip) for Windows 64-bit.  
    Create suggested install folder and extract contents of ZIP file to:  
    `C:\HashiCorp\Packer\bin`  

2.	Install [Git 2.44.0](https://github.com/git-for-windows/git/releases/download/v2.44.0.windows.1/Git-2.44.0-64-bit.exe) for Windows 64-bit.

3.	Install [jq 1.7.1](https://github.com/jqlang/jq/releases/download/jq-1.7.1/jq-win64.exe) for Windows 64-bit.  
    Create suggested install folder and rename binary to:  
    `C:\Program Files\Git\usr\local\bin\jq.exe`

### Configuration and Validation - Windows 64-Bit

1.	Set Windows Environment `PATH` to:

    ```bash
    PATH=C:\HashiCorp\Packer\bin;C:\Program Files\Git\usr\local\bin;%PATH%
    ```

2.	Reboot Windows.

3.	Launch Git Bash.  
    Start Menu -- > All apps -- > Git -- > Git Bash

4.	Validate installed command-line tools:

    ```bash
    $ packer --version
    1.10.2

    $ git --version
    git version 2.44.0.windows.1

    $ jq --version
    jq-1.7.1
    ```

5.	Configure Git for local user:

    ```bash
    $ git config --global user.name "<your_name>"
    $ git config --global user.email "<your_email>"
    $ git config --global --list
    ```

## Get the Code

1.	Create a folder for your AppD Cloud Platform project:

    ```bash
    $ mkdir -p /<drive>/projects
    $ cd /<drive>/projects
    ```

2.	Get the code from GitHub:

    ```bash
    $ git clone https://github.com/Appdynamics/AppD-Cloud-Platform.git
    $ cd AppD-Cloud-Platform
    ```

## Build the Immutable VM Images with Packer

The AppDynamics Cloud Platform project currently supports immutable VM image builds for GCP. In the future, we will be adding support for Amazon AWS and Microsoft Azure. Click on a link below for platform-specific instructions and Bill-of-Materials.

-	[GCP CentOS 7.9 VMs](GCP_VM_BUILD_INSTRUCTIONS.md): Instructions
