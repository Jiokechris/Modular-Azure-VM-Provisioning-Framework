# Modular Azure VM Provisioning Framework

A modular Azure CLI-based automation framework for provisioning and managing Azure Virtual Machines using Bash scripting.

This project was built to demonstrate practical cloud engineering skills including Azure resource deployment, infrastructure automation, modular scripting, version control, security integration, and Infrastructure as Code (IaC) practices.

---

## Overview

The framework automates the end-to-end deployment of Azure infrastructure by breaking deployment tasks into reusable modules.

Instead of maintaining a single large script, each deployment component is separated into dedicated modules responsible for specific infrastructure tasks such as resource group creation, networking, SSH key management, VM provisioning, validation, and cleanup.

This modular design improves:

* Maintainability
* Reusability
* Scalability
* Troubleshooting
* Team collaboration

---

## Features

### Infrastructure Automation

* Automated Azure VM deployment
* Resource Group creation
* Virtual Network creation
* Subnet creation
* Network Security Group configuration
* Public IP allocation
* SSH key generation and management

### Deployment Management

* Pre-deployment validation checks
* Deployment summaries
* Logging and troubleshooting support
* Automated cleanup process

### Version Control

* Git repository management
* GitHub integration
* Feature branching workflow
* Pull Request workflow

### Future Enhancements

* Azure Key Vault integration
* Secure secret retrieval
* Terraform-based infrastructure provisioning
* CI/CD with GitHub Actions
* Remote Terraform state management

---

## Project Structure

```text
azure-vm-project/
│
├── deploy.sh
├── config.env
├── cloud-init.yaml
├── README.md
│
├── logs/
│
└── modules/
    │
    ├── prerequisites.sh
    ├── resource_group.sh
    ├── network.sh
    ├── ssh.sh
    ├── vm.sh
    ├── verification.sh
    ├── summary.sh
    └── cleanup.sh
```

---

## Module Responsibilities

### prerequisites.sh

Performs environment validation before deployment.

Responsibilities:

* Verify Azure CLI installation
* Verify Azure authentication
* Validate required commands
* Check deployment prerequisites

---

### resource_group.sh

Creates and manages Azure Resource Groups.

Responsibilities:

* Create Resource Groups
* Verify Resource Group existence
* Handle Resource Group configuration

---

### network.sh

Deploys networking components.

Responsibilities:

* Create Virtual Networks
* Create Subnets
* Create Network Security Groups
* Configure security rules
* Associate networking resources

---

### ssh.sh

Manages SSH key generation and authentication.

Responsibilities:

* Generate SSH key pairs
* Store private keys securely
* Configure VM SSH access

---

### vm.sh

Deploys Azure Virtual Machines.

Responsibilities:

* Create VM instances
* Configure VM settings
* Attach networking resources
* Configure administrative access

---

### verification.sh

Validates deployment success.

Responsibilities:

* Verify VM deployment
* Verify network configuration
* Verify connectivity
* Verify resource availability

---

### summary.sh

Displays deployment output.

Responsibilities:

* Display VM details
* Display Public IP
* Display Resource Group information
* Provide deployment summary

---

### cleanup.sh

Handles resource removal.

Responsibilities:

* Delete deployed resources
* Remove test environments
* Clean up deployment artifacts

---

## Configuration Files

### deploy.sh

The main orchestration script.

This script coordinates the deployment process by calling all required modules in the correct sequence.

Example:

```bash
./deploy.sh
```

---

### config.env

Stores deployment variables and environment-specific settings.

Examples:

```text
RESOURCE_GROUP=my-rg
LOCATION=eastus
VM_NAME=myvm
ADMIN_USER=azureuser
```

---

### cloud-init.yaml

Stores deployment configuration and project settings in a structured format.

Examples may include:

* Environment definitions
* VM specifications
* Network configurations
* Deployment options

---

## Deployment Workflow

```text
Start
 │
 ▼
Load Configuration
(config.env / cloud-init.yaml)
 │
 ▼
Run Prerequisite Checks
 │
 ▼
Create Resource Group
 │
 ▼
Create Network Resources
 │
 ▼
Generate SSH Keys
 │
 ▼
Deploy Virtual Machine
 │
 ▼
Run Verification Checks
 │
 ▼
Generate Deployment Summary
 │
 ▼
Deployment Complete
```

---

## Technologies Used

* Microsoft Azure
* Azure CLI
* Bash Scripting
* Git
* GitHub
* Linux

---

## Azure Resources Deployed

* Resource Groups
* Virtual Machines
* Virtual Networks
* Subnets
* Network Security Groups
* Public IP Addresses
* SSH Keys

---

## Git Workflow

### Clone Repository

```bash
git clone <repository-url>
```

### Create Feature Branch

```bash
git checkout -b feature-name
```

### Stage Changes

```bash
git add .
```

### Commit Changes

```bash
git commit -m "Description of change"
```

### Push Changes

```bash
git push origin feature-name
```

### Create Pull Request

1. Push branch to GitHub
2. Open repository
3. Select Compare & Pull Request
4. Review changes
5. Merge Pull Request

---

## Current Learning Roadmap

### Phase 1 – Version Control

* [x] Git Installation
* [x] GitHub Repository Creation
* [x] Project Upload to GitHub
* [x] Branch Management
* [x] Pull Requests

### Phase 2 – Security

* [ ] Azure Key Vault Creation
* [ ] Secret Storage
* [ ] Secret Retrieval
* [ ] Secret Integration into Deployment Scripts

### Phase 3 – Infrastructure as Code

* [ ] Terraform Installation
* [ ] Terraform Resource Group Deployment
* [ ] Terraform Plan
* [ ] Terraform Apply
* [ ] Terraform Destroy

### Phase 4 – Advanced Automation

* [ ] GitHub Actions
* [ ] CI/CD Pipeline
* [ ] Automated Validation
* [ ] Infrastructure Testing

---

## Future Improvements

* Azure Key Vault integration
* Secure credential management
* Terraform migration
* Multi-environment deployments
* Automated CI/CD pipelines
* Infrastructure testing and validation
* Monitoring and alerting integration

---

## Author

### Chijioke C. Odoh

Cloud Infrastructure & Systems Engineer

GitHub:
https://github.com/Jiokechris

LinkedIn:
https://www.linkedin.com/in/chijioke-odoh-a263001bb
