# Google Cloud Platform (GCP) Deployment Instructions

Follow these instructions to build the GCP CentOS 7.8 AMI images:

-	__AppD-Cloud-Platform-HA VM__: An APM Platform stand-alone VM with an AppDynamics Controller.

Before building the AppD Cloud Platform HA VM images for GCP, it is recommended that you install the
Google Cloud SDK (CLI). This will allow you to cleanup and delete any resources created by the Packer
builds when you are finished. It will also provide the ability to easily purge old AMI images while keeping the latest. Note that in AWS CLI version 2, the required Python 3 libraries are now embedded in the installer and no longer need to be installed separately.

## GCP-Specific Installation Instructions - macOS

Here is a list of the recommended open source software to be installed on the host macOS machine:

-	Google Cloud SDK 317.0.0 (command-line interface)

Perform the following steps to install the needed software:

1.	Install [Google Cloud SDK 317.0.0](https://cloud.google.com/sdk/docs/install#mac) for macOS 64-bit.  
    ```bash
    $ brew cask install google-cloud-sdk
    ```

2.	Validate installed command-line tools:

    ```bash
    $ gcloud --version
    Google Cloud SDK 317.0.0
    bq 2.0.62
    core 2020.10.23
    gsutil 4.54
    ```

## Prepare for the Build

All user credentials and installation inputs are driven by environment variables and can be configured within the `set_appd_cloud_kickstart_env.sh` script you will create in `./bin`. There are LOTS of options, but most have acceptable defaults. You only need to concentrate on a handful that are uncommented in the template file.

In particular, you will need to supply your AppDynamics login credentials to the [download site](https://download.appdynamics.com/download/). You will also need to provide an AWS Access Key ID and Secret Access Key from a valid AWS account.

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

    The first 4 are mandatory and the others are optional, but helpful. If you are building the AMI images in the `us-east-1` region (N. Virginia), the region-related variables can be left alone.

    ```bash
    appd_username="<Your_AppDynamics_Download_Site_Email>"
    appd_password="<Your_AppDynamics_Download_Site_Password>"

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

1.	Build the __AppD-Cloud-Platform-HA VM__ CentOS 7.8 AMI image:

    This will take several minutes to run.

    ```bash
    $ cd ~/projects/AppD-Cloud-Platform/builders/packer/gcp
    $ packer build appd-cloud-platform-ha-centos78.json
    ```

    If the build fails, check to ensure the accuracy of all variables edited above--including items such as
    spaces between access keys and the ending parentheses.

### GCP CentOS 7.8 Bill-of-Materials

__AppD-Cloud-Platform-HA VM__ - The following utilities and application performance management applications are pre-installed:

-	Ansible 2.9.15
-	AppDynamics Enterprise Console 20.10.5 Build 23565
	-	AppDynamics Controller 20.10.5 Build 2556
	-	AppDynamics Events Service 4.5.2.0 Build 20640
	-	AppDynamics EUM Server 20.10.1 Build 32458
-	Docker 19.03.13 CE
	-	Docker Bash Completion
	-	Docker Compose 1.27.4
	-	Docker Compose Bash Completion
-	Git 2.29.2
	-	Git Bash Completion
	-	Git-Flow 1.12.3 (AVH Edition)
	-	Git-Flow Bash Completion
-	Google Cloud SDK 317.0.0 (command-line interface)
-	Java SE JDK 8 Update 272 (Amazon Corretto 8)
-	jq 1.6 (command-line JSON processor)
-	MySQL Shell 8.0.21
-	Python 2.7.5
	-	Pip 20.2.4
-	Python 3.6.8
	-	Pip 20.2.4
-	VIM - Vi IMproved 8.2

## Deploy the Infrastructure with Terraform

1.	Create the Terraform `terraform.tfvars` file. The `terraform.tfvars` file is automatically loaded by
    Terraform and provides a convenient way to override input parameters found in
    [`variables.tf`](builders/terraform/gcp/appd-cloud-platform/variables.tf). Two of the most important
    variables are:

    | Variable                        | Description                                                                                                                                                                                                                                                                                               |
    |---------------------------------|------------------------------------------------------------|
    | `gcp_source_image_project`      | The source image project.
    | `gcp_source_image`              | The source disk image name.

    ```bash
    $ cd ~/projects/AppD-Cloud-Platform/builders/terraform/gcp/appd-cloud-platform

    $ vi terraform.tfvars
    ...
    # the source image project.
    gcp_source_image_project = "<your-gcp-project-name-here>"

    # the source disk image name.
    gcp_source_image = "appd-cloud-platform-20104-ha-centos78-2020-11-02"
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

