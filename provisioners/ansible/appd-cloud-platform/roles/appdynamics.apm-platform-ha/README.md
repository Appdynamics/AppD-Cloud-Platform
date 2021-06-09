# Ansible AppDynamics APM-Platform-HA Role 

The Ansible AppDynamics role installs and configures an APM Platform HA configuration.
The role installs version `20.7.0.xxxxx` of the APM Platform by default.

## Setup

### Requirements

- Requires Ansible v2.9+.
- Supports CentOS 7.x distributions.

### Installation

Install the [APM Platform HA role][1] from Ansible Galaxy on your Ansible server:

```shell
ansible-galaxy install appdynamics.apm-platform-ha
```

To deploy the AppDynamics APM Platform HA on VM hosts, set your AppDynamics account
login credentials as environment variables (referenced in the 'environment' section and
add the APM Platform HA role:

```text
- name: install appdynamics apm platform ha
  hosts: all
  gather_facts: yes
  any_errors_fatal: yes
  environment:
    appd_platform_user_name: "{{ lookup('env', 'appd_platform_user_name') | default('appduser', true) }}"
    appd_platform_user_group: "{{ lookup('env', 'appd_platform_user_group') | default('appduser', true) }}"

  roles:
    - role: appdynamics.apm-platform-ha
```

#### Role variables

| Variable                                   | Description                                                                                                                                                                                                                                                                                               |
|--------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `appd_home`                                | AppD home directory (defaults to '/opt/appdynamics').
| `appd_platform_user_name`                  | Platform installation user name (defaults to 'appduser').
| `appd_platform_user_group`                 | Platform installation group (defaults to 'appduser').


#### Dependencies

A list of other roles hosted on Galaxy should go here, plus any details in regards to parameters that may need to be set for other roles, or variables that are used from other roles.

#### License

Apache 2.0

#### Author Information

[1]: https://galaxy.ansible.com/appdynamics/apm-platform-ha
