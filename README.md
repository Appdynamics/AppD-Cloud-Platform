# AppD Cloud Platform

The AppDynamics Cloud Platform is a DevOps project to help automate the deployment of an HA configuration
of the AppDynamics Platform in the cloud. It consists of a code repository with Infrastructure as Code (IaC)
artifacts, software provisioning modules, and a runbook with step-by-step instructions for deploying the
platform.

It is based on the concepts of Immutable Infrastructure and Idempotent provisioning.

## Overview

When installing the AppDynamics Platform software, the provisioning and configuration of an on-premise HA
installation is an extremely tedious and time-consuming challenge for IT administrators. The purpose of this
project is to significantly reduce the time required for these installation activities using Terraform and
Ansible.

## Get Started

To deploy the AppDynamics Cloud Platform, first step is to set-up your local environment by installing the
needed open source software.

### Prerequisites
You install Terraform and Ansible on a control node, (usually your local laptop,) which then uses the
Google Cloud SDK (gcloud CLI) and/or SSH to communicate with your cloud resources and managed nodes.  

__NOTE:__ Ansible installations can be run from any machine with Python 2 (version 2.7) or Python 3
(versions 3.5 and higher) installed. This includes Red Hat, Debian, CentOS, macOS, any of the BSDs, and
so on. However, Windows is not currently supported for the Ansible control node.

## Installation Instructions - macOS

The following open source software needs to be installed on the host macOS machine:

-	Homebrew 2.5.2
	-	Command Line Tools (CLT) for Xcode
-	Git 2.28.0
-	Google Cloud SDK (gcloud CLI) 311.0.0
-	Terraform 0.13.3
-	Ansible 2.9.13

Perform the following steps to install the needed software:

1.	Install [Command Line Tools (CLT) for Xcode](https://developer.apple.com/downloads).  
    `$ xcode-select --install`  

    __NOTE:__ Most Homebrew formulae require a compiler. A handful require a full Xcode installation. You
    can install [Xcode](https://itunes.apple.com/us/app/xcode/id497799835), the [CLT](https://developer.apple.com/downloads),
    or both; Homebrew supports all three configurations. Downloading Xcode may require an Apple Developer
    account on older versions of Mac OS X. Sign up for free [here](https://developer.apple.com/register/index.action).  

2.	Install the [Homebrew 2.5.2](https://brew.sh/) package manager for macOS 64-bit. Paste the following into a macOS Terminal prompt:  
    `$ /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"`

3.	Install [Git 2.28.0](https://git-scm.com/downloads) for macOS 64-bit.  
    `$ brew install git`  

4.	Install [Google Cloud SDK (gcloud CLI) 311.0.0](https://cloud.google.com/sdk/docs/install#mac) for macOS 64-bit.  
    `$ brew cask install google-cloud-sdk`  

5.	Install [Terraform 0.13.3](https://www.terraform.io/downloads.html) for macOS 64-bit.  
    `$ brew install hashicorp/tap/terraform`  

6.	Install [Ansible 2.9.13](https://ansible.com/) for macOS 64-bit.  
    `$ brew install ansible`  

## Configuration and Validation - macOS

1.	Validate installed command-line tools:

    ```bash
    $ brew --version
    Homebrew 2.5.2
    $ brew doctor
    Your system is ready to brew.

    $ git --version
    git version 2.28.0

    $ gcloud --version
    Google Cloud SDK 311.0.0
    ...

    $ terraform --version
    Terraform v0.13.3

    $ ansible --version
    ansible 2.9.13
    ...
    ```

2.	Configure Git for local user:

    ```bash
    $ git config --global user.name "<your_name>"
    $ git config --global user.email "<your_email>"
    $ git config --global --list
    ```

## Setup the Google Cloud SDK

In order for Terraform to run operations on your behalf, you must configure the Google Cloud SDK (gcloud CLI).
For more information, see the [GCP quickstart guide](https://cloud.google.com/sdk/docs/quickstart).

1.	Authorize gcloud CLI utility to access GCP with your user account credentials:

    Run the following command to obtain access credentials for your user account via a browser-based authorization
    flow. When this command completes successfully, it sets the active account in the current configuration.

    ```bash
    $ gcloud auth login
    ```

2.	Set the default Project ID and validate the configuration for the Cloud Platform project:

    To create resources using the gcloud CLI, you must configuration a default project. If you need help, see the
    [Creating and managing projects](https://cloud.google.com/resource-manager/docs/creating-managing-projects)
    user guide.

    ```bash
    $ gcloud config set project <your_project_id>
    ```

    Validate the configuration:

    ```bash
    $ gcloud config list
    $ gcloud config configurations list
    ```

3.	Create a default service account and add the IAM policy bindings:

    With a default service account, your application can retrieve the service account credentials automatically to
    call Google Cloud APIs.

    ```bash
    $ gcloud iam service-accounts create devops \
        --display-name="DevOps Service Account" \
        --description="DevOps service account for Terraform builds."

    $ export G_PROJECT=$(gcloud info --format='value(config.project)')
    $ export SA_EMAIL=$(gcloud iam service-accounts list --filter="name:devops" --format='value(email)')

    $ gcloud projects add-iam-policy-binding \
        --member serviceAccount:$SA_EMAIL \
        --role roles/compute.admin $G_PROJECT
    $ gcloud projects add-iam-policy-binding \
        --member serviceAccount:$SA_EMAIL \
        --role roles/iam.serviceAccountUser $G_PROJECT
    $ gcloud iam service-accounts keys create \
        --iam-account $SA_EMAIL shared/keys/gcp-devops-keys.json
    ```

    For reference, see [Authenticating as a service account](https://cloud.google.com/docs/authentication/production)
    in the online documentation.  

## Get the Code

1.	Create a folder for your AppD Cloud Platform project:

    ```bash
    $ mkdir -p /<path>/projects
    $ cd /<path>/projects
    ```

2.	Get the code from GitHub:

    ```bash
    $ git clone https://github.com/Appdynamics/AppD-Cloud-Platform.git
    $ cd AppD-Cloud-Platform
    ```

**NOTE:** The complete documentation is still currently a work-in-progress.
