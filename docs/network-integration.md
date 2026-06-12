# Custom Network Integration

## Overview

This phase of the project focused on replacing Azure's automatically generated networking resources with a fully custom network architecture.

The objective was to gain complete control over network provisioning, security configuration, and VM connectivity while following a modular Infrastructure as Code approach.

---

# Previous Architecture

The VM was originally deployed using:

```text
az vm create
```

Azure automatically provisioned:

* Virtual Network
* Subnet
* Network Security Group
* Public IP Address
* Network Interface

While convenient, this approach hides networking implementation details and offers limited customization.

---

# New Architecture

Networking resources are now created explicitly before VM deployment.

```text
Resource Group
    ↓
Virtual Network
    ↓
Subnet
    ↓
Network Security Group
    ↓
NSG Rules
    ↓
Public IP
    ↓
Network Interface
    ↓
Virtual Machine
```

---

# Components Created

## Virtual Network

Created a dedicated VNet for the deployment.

```text
Address Space:
10.0.0.0/16
```

---

## Subnet

Created a dedicated subnet inside the VNet.

```text
Subnet:
10.0.1.0/24
```

---

## Network Security Group

Created a custom NSG to control inbound access.

### Rules Configured

| Rule        | Port | Purpose               |
| ----------- | ---- | --------------------- |
| allow-ssh   | 22   | Administrative access |
| allow-http  | 80   | Website access        |
| allow-https | 443  | Secure website access |

---

## Public IP

Created a Standard SKU static Public IP.

Benefits:

* Predictable endpoint
* Better production alignment
* Independent lifecycle management

---

## Network Interface

Created a dedicated NIC and attached:

* VNet
* Subnet
* Public IP
* NSG

The VM was deployed using the custom NIC instead of Azure-generated networking.

---

# Challenges Encountered

## Challenge 1: Website Not Reachable Externally

### Symptoms

Deployment completed successfully.

VM provisioning succeeded.

Nginx installed successfully.

However:

```text
curl http://PUBLIC_IP
```

failed from outside Azure.

---

### Investigation

Validated:

* Public IP assignment
* NIC attachment
* VM deployment
* Nginx installation

Confirmed the VM was using the intended custom NIC.

---

### Root Cause

Network security configuration required validation after migrating from Azure-managed networking to manually provisioned infrastructure.

---

### Resolution

Verified effective NSG rules and ensured the networking path correctly allowed:

* TCP 22
* TCP 80
* TCP 443

Result:

External access to the web server was restored.

---

## Challenge 2: Health Verification Failure

### Symptoms

The website was accessible through a browser but automated verification reported failure.

---

### Investigation

Manual testing returned:

```bash
curl http://PUBLIC_IP
```

Expected HTML content was returned successfully.

---

### Root Cause

The HTTP response code contained hidden whitespace characters which caused the Bash comparison to fail.

---

### Resolution

Normalized the response before comparison:

```bash
tr -d '[:space:]'
```

Result:

HTTP 200 responses were detected correctly.

---

# Lessons Learned

* Azure default networking simplifies deployment but limits visibility.
* Custom network provisioning provides greater control and troubleshooting insight.
* Effective NSG rule validation is critical during network migrations.
* VM connectivity should be verified independently from application verification.
* Health-check scripts should sanitize output before performing comparisons.

---

# Outcome

Successfully migrated from Azure-managed networking to a fully custom network architecture.

The deployment now provisions:

* VNet
* Subnet
* NSG
* NSG Rules
* Public IP
* NIC

before VM creation, providing complete control over network design and security configuration.
