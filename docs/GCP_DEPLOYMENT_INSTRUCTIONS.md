# Google Cloud Platform (GCP) Deployment Instructions

This document explains the steps needed to deploy the AppDynamics Cloud Platform HA configuration to GCP.

## Before You Begin

Before deploying the platform to GCP, you will need to set-up your GCP account and install the Google Cloud
SDK (CLI) in your local environment.  

Follow these instructions to build the GCP Compute Engine CentOS 7.9 image:

This document explains how to set-up your GCP account and local environment in order to deploy the AppDynamics

Before deploying the platform to GCP, it is recommended that you install the
Google Cloud SDK (CLI).

The AppDynamics Cloud Platform is a DevOps project to help automate the deployment of an HA configuration
of the AppDynamics Platform in the cloud using the on-premise installers. It consists of a code repository
with Infrastructure as Code (IaC) artifacts, software provisioning modules, and a runbook with step-by-step
instructions for deploying the platform on Amazon AWS and the Google Cloud Platform (GCP).

Before building the AppD Cloud Platform HA VM images for GCP, it is recommended that you install the
Google Cloud SDK (CLI). This will allow you to cleanup and delete any resources created by the Packer
builds when you are finished. It will also provide the ability to easily purge old AMI images while keeping the latest. Note that in AWS CLI version 2, the required Python 3 libraries are now embedded in the installer and no longer need to be installed separately.


brew cask install google-cloud-sdk
gcloud --version
gcloud components list
gcloud components update
gcloud config set disable_usage_reporting true

gcloud auth login
gcloud config set project appd-cloud-kickstart
gcloud config list
gcloud config configurations list
gcloud iam service-accounts create devops --display-name="DevOps Service Account" --description="DevOps service account for Packer and Terraform builds."
gcloud iam service-accounts create devops --display-name="DevOps Service Account" --description="DevOps service account for Packer builds."
gcloud iam service-accounts create devops --display-name="DevOps Service Account" --description="DevOps service account for Terraform builds."
export G_PROJECT=$(gcloud info --format='value(config.project)')
export SA_EMAIL=$(gcloud iam service-accounts list --filter="name:devops" --format='value(email)')
gcloud projects add-iam-policy-binding --member serviceAccount:$SA_EMAIL --role roles/compute.admin $G_PROJECT
gcloud projects add-iam-policy-binding --member serviceAccount:$SA_EMAIL --role roles/iam.serviceAccountUser $G_PROJECT

gcloud auth application-default login --no-launch-browser
gcloud iam service-accounts keys create --iam-account $SA_EMAIL ~/projects/AppD-Cloud-Platform/shared/keys/gcp-devops.json
gcloud compute regions list
gcloud compute zones list
gcloud compute images add-iam-policy-binding appd-cloud-platform-2085-ha-centos79-2020-11-19 --member='allAuthenticatedUsers' --role='roles/compute.imageUser'
gcloud services list
gcloud compute machine-types list

gcloud auth login --no-launch-browser
gcloud config set project appd-cloud-platform
gcloud config list
gcloud config configurations list
gcloud services list
gcloud services list --available
gcloud services list --available | grep Compute
gcloud services list --enabled

cat $HOME/.config/gcloud/application_default_credentials.json
gcloud compute zones list --project=appd-cloud-platform
gcloud projects list

gcloud services enable cloudresourcemanager.googleapis.com
gcloud services enable cloudbilling.googleapis.com
gcloud services enable iam.googleapis.com
gcloud services enable compute.googleapis.com
gcloud services enable serviceusage.googleapis.com

gcloud services enable oauth2.googleapis.com
gcloud services enable gkeconnect.googleapis.com
gcloud services enable gkehub.googleapis.com
gcloud services enable container.googleapis.com
gcloud services enable servicenetworking.googleapis.com

# https://www.padok.fr/en/blog/kubernetes-google-cloud-terraform-cluster
gcloud services enable compute.googleapis.com
gcloud services enable servicenetworking.googleapis.com
gcloud services enable cloudresourcemanager.googleapis.com
gcloud services enable container.googleapis.com

# associated roles
gcloud projects add-iam-policy-binding $G_PROJECT --member serviceAccount:serviceAccount:$SA_EMAIL --role roles/container.admin
gcloud projects add-iam-policy-binding $G_PROJECT --member serviceAccount:serviceAccount:$SA_EMAIL --role roles/compute.admin
gcloud projects add-iam-policy-binding $G_PROJECT --member serviceAccount:serviceAccount:$SA_EMAIL --role roles/iam.serviceAccountUser
gcloud projects add-iam-policy-binding $G_PROJECT --member serviceAccount:serviceAccount:$SA_EMAIL --role roles/resourcemanager.projectIamAdmin


gcloud iam service-accounts list
gcloud projects get-iam-policy <YOUR GCLOUD PROJECT>  --flatten="bindings[].members" --format='table(bindings.role)' --filter="bindings.members:devops
gcloud projects get-iam-policy $G_PROJECT --flatten="bindings[].members" --format='table(bindings.role)' --filter="bindings.members:devops"

gcloud iam service-accounts list
gcloud projects get-iam-policy $G_PROJECT --flatten="bindings[].members" --format='table(bindings.role)' --filter="bindings.members:618610343693-compute"

gcloud projects get-iam-policy $G_PROJECT --flatten="bindings[].members" --format='table(bindings.role)' --filter="bindings.members:devops"
gcloud projects add-iam-policy-binding --member serviceAccount:$SA_EMAIL --role roles/editor $G_PROJECT
gcloud projects get-iam-policy $G_PROJECT --flatten="bindings[].members" --format='table(bindings.role)' --filter="bindings.members:devops"
gcloud projects add-iam-policy-binding --member serviceAccount:$SA_EMAIL --role roles/owner $G_PROJECT
gcloud projects get-iam-policy $G_PROJECT --flatten="bindings[].members" --format='table(bindings.role)' --filter="bindings.members:devops"

gcloud projects remove-iam-policy-binding --member serviceAccount:$SA_EMAIL --role roles/editor $G_PROJECT
gcloud projects get-iam-policy $G_PROJECT --flatten="bindings[].members" --format='table(bindings.role)' --filter="bindings.members:devops"
gcloud projects remove-iam-policy-binding --member serviceAccount:$SA_EMAIL --role roles/owner $G_PROJECT
gcloud projects add-iam-policy-binding --member serviceAccount:$SA_EMAIL --role roles/editor $G_PROJECT
gcloud projects add-iam-policy-binding --member serviceAccount:$SA_EMAIL --role roles/owner $G_PROJECT
gcloud projects remove-iam-policy-binding --member serviceAccount:$SA_EMAIL --role roles/owner $G_PROJECT
gcloud projects remove-iam-policy-binding --member serviceAccount:$SA_EMAIL --role roles/editor $G_PROJECT
gcloud projects get-iam-policy $G_PROJECT --flatten="bindings[].members" --format='table(bindings.role)' --filter="bindings.members:devops"

https://console.cloud.google.com/projectselector2/home/dashboard


gcp-lpad[centos]$ terraform plan -out terraform-appd-cloud-platform.tfplan
Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.


Error: Attempted to load application default credentials since neither `credentials` nor `access_token` was set in the provider block.  No credentials loaded. To use your gcloud credentials, run 'gcloud auth application-default login'.  Original error: google: could not find default credentials. See https://developers.google.com/accounts/docs/application-default-credentials for more information.

gcp-lpad[centos]$ gcloud auth application-default login
Go to the following link in your browser:

    https://accounts.google.com/o/oauth2/auth?client_id=764086051850-6qr4p6gpi6hn506pt8ejuq83di341hur.apps.googleusercontent.com&redirect_uri=urn%3Aietf%3Awg%3Aoauth%3A2.0%3Aoob&scope=openid+https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fuserinfo.email+https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fcloud-platform+https%3A%2F%2Fwww.googleapis.com%2Fauth%2Faccounts.reauth&code_challenge=WLuu4Clqtj2FRhG3gaBq8XMA1Lj8WxODkWsZCARTKEQ&code_challenge_method=S256&access_type=offline&response_type=code&prompt=select_account


Enter verification code: 4/1AfDhmrgXvBN2b9Vk0iNrG2DRNRfG-MXolVfo5vNQWE5EPqDo6FXCeIrWUxI

Credentials saved to file: [/home/centos/.config/gcloud/application_default_credentials.json]

These credentials will be used by any library that requests Application Default Credentials (ADC).
/usr/lib64/google-cloud-sdk/lib/third_party/google/auth/_default.py:69: UserWarning: Your application has authenticated using end user credentials from Google Cloud SDK without a quota project. You might receive a "quota exceeded" or "API not enabled" error. We recommend you rerun `gcloud auth application-default login` and make sure a quota project is added. Or you can use service accounts instead. For more information about service accounts, see https://cloud.google.com/docs/authentication/
  warnings.warn(_CLOUD_SDK_CREDENTIALS_WARNING)

Quota project "test-appd-cloud-platform" was added to ADC which can be used by Google client libraries for billing and quota. Note that some services may still bill the project owning the resource.


## Build the GCP Compute Engine Image with Packer

## Deploy the Infrastructure with Terraform

## Provision the AppD Cloud Platform with Ansible

Follow these instructions to build the GCP Compute Engine CentOS 7.9 image:

-	__AppD-Cloud-Platform-HA VM__: A stand-alone VM with an AppDynamics Cloud Platform 21.4.17 HA configuration on CentOS 7.9.

Before building the AppD Cloud Platform HA VM images for GCP, it is recommended that you install the
Google Cloud SDK (CLI). This will allow you to cleanup and delete any resources created by the Packer
builds when you are finished. It will also provide the ability to easily purge old AMI images while keeping the latest. Note that in AWS CLI version 2, the required Python 3 libraries are now embedded in the installer and no longer need to be installed separately.

## GCP-Specific Installation Instructions - macOS

Here is a list of the recommended open source software to be installed on the host macOS machine:

-	Google Cloud SDK 402.0.0 (command-line interface)

Perform the following steps to install the needed software:

1.	Install [Google Cloud SDK 402.0.0](https://cloud.google.com/sdk/docs/install#mac) for macOS 64-bit.  
    ```bash
    $ brew cask install google-cloud-sdk
    ```

2.	Validate installed command-line tools:

    ```bash
    $ gcloud --version
    Google Cloud SDK 402.0.0
    ...
    ```

## Prepare for the Build

All user credentials and installation inputs are driven by environment variables and can be configured within the `set_appd_cloud_kickstart_env.sh` script you will create in `./bin`. There are LOTS of options, but most have acceptable defaults. You only need to concentrate on a handful that are uncommented in the template file.

In particular, you will need to supply your AppDynamics login credentials to the [download site](https://accounts.appdynamics.com/downloads/). You will also need to provide an AWS Access Key ID and Secret Access Key from a valid AWS account.

The build will __fail__ if they are not set.

To prepare for the build, perform the following steps:

1.	Customize your AppD Cloud Platform project environment:

    Copy the template file and edit `set_appd_cloud_kickstart_env.sh` located in `./bin` to customize the environment variables for your environment.

    ```bash
    $ cd /<drive>/projects/AppD-Cloud-Platform/bin
    $ cp -p set_appd_cloud_kickstart_env.sh.template set_appd_cloud_kickstart_env.sh
    $ vi set_appd_cloud_kickstart_env.sh
    ```

    The following environment variables are the most common to be overridden. They are grouped by sections in the file, so you will have to search to locate the exact line. For example, the AWS-related variables are at the end of the file.

    The first two are mandatory and the others are optional, but helpful. If you are building the AMI images in the `us-east-1` region (N. Virginia), the region-related variables can be left alone.

    ```bash
    AWS_ACCESS_KEY_ID="<Your_AWS_ACCESS_KEY_ID>"
    AWS_SECRET_ACCESS_KEY="<Your_AWS_SECRET_ACCESS_KEY>"

    aws_ami_owner="<Your Firstname> <Your Lastname>"
    aws_cli_default_region_name="us-east-1"         # example for N. Virginia.
    aws_ami_region="us-east-1"                      # example for N. Virginia.
    ```

    Save and source the environment variables file in order to define the variables in your shell.

    ```bash
    $ source ./set_appd_cloud_kickstart_env.sh
    ```

    Validate the newly-defined environment variables via the following commands:

    ```bash
    $ env | grep -i ^aws | sort
    $ env | grep -i ^appd | sort
    ```

2.	Supply a valid AppDynamics Controller license file:

	-	This license can be supplied by any AppDynamics SE
		-	It is recommended to have at least 10 APM, 10 server, 10 network, 5 DB, 1 unit of each Analytics and 1 unit of each RUM within the license key.
		-	Copy your AppDynamics Controller `license.lic` and rename it to `provisioners/scripts/centos/tools/appd-controller-license.lic`.


## Build the GCP Compute Image with Packer

1.	Build the __AppD-Cloud-Platform-HA VM__ CentOS 7.9 AMI image:

    This will take several minutes to run.

    ```bash
    $ cd ~/projects/AppD-Cloud-Platform/builders/packer/gcp
    $ packer build appd-cloud-platform-ha-centos79.json
    ```

    If the build fails, check to ensure the accuracy of all variables edited above--including items such as
    spaces between access keys and the ending parentheses.

### GCP CentOS 7.9 Bill-of-Materials

__AppD-Cloud-Platform-HA VM__ - The following utilities and application performance management applications are pre-installed:

-	Ansible 2.9.27
-	AppDynamics Enterprise Console 21.4.17 Build 24779
	-	AppDynamics Controller 21.4.17 Build 1609
	-	AppDynamics Events Service 4.5.2 Build 20670
	-	AppDynamics EUM Server 21.4.4 Build 34564
-	Docker 20.10.18 CE
	-	Docker Bash Completion
	-	Docker Compose 1.29.2
	-	Docker Compose Bash Completion
-	Git 2.37.3
	-	Git Bash Completion
	-	Git-Flow 1.12.3 (AVH Edition)
	-	Git-Flow Bash Completion
-	Google Cloud SDK 402.0.0 (command-line interface)
-	Java SE JDK 8 Update 342 (Amazon Corretto 8)
-	jq 1.6 (command-line JSON processor)
-	MySQL Shell 8.0.27
-	Python 2.7.5
	-	Pip 22.2.2
-	Python 3.6.8
	-	Pip 22.2.2
-	VIM - Vi IMproved 9.0
-	yq 4.27.5 (command-line YAML processor)

## Deploy the Infrastructure with Terraform

1.	Create the Terraform `terraform.tfvars` file. The `terraform.tfvars` file is automatically loaded by
    Terraform and provides a convenient way to override input parameters found in
    [`variables.tf`](builders/terraform/gcp/appd-cloud-platform/variables.tf). Two of the most important
    variables are:

    | Variable                        | Description                                                                                                                                                                                                                                                                                               |
    |---------------------------------|------------------------------------------------------------|
    | `gcp_source_image_project`      | The source image project.
    | `gcp_source_image_family`       | The source image family.

    ```bash
    $ cd ~/projects/AppD-Cloud-Platform/builders/terraform/gcp/appd-cloud-platform

    $ vi terraform.tfvars
    ...
    # the source image project.
    gcp_source_image_project = "<your-gcp-project-name-here>"

    # the source image family.
    gcp_source_image_family = "appd-cloud-platform-ha-centos79-images"
    ...
    ```

2.	Deploy the AppD Cloud Platform infrastructure on GCP. Execute the following Terraform lifecycle commands in sequence:

    ```bash
    $ terraform --version
    $ terraform init
    $ terraform validate
    $ terraform plan -out terraform-appd-cloud-platform.tfplan
    $ terraform apply terraform-appd-cloud-platform.tfplan
    ```

