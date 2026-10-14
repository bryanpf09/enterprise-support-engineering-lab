# Enterprise Support Engineering Lab

A hands-on, self-directed **enterprise application support and troubleshooting** project. This lab uses virtualized Windows servers, Active Directory, SQL Server, and reporting services to build the infrastructure behind a business-critical application.

The approach is to **deploy the environment, verify a healthy baseline, and then investigate controlled failures** using logs, PowerShell, network diagnostics, and root-cause analysis. The goal is to demonstrate transferable support-engineering skills—not simply install a particular product.

## What Is BIS, and Why Use It?

**Building Integration System (BIS)** is an enterprise security management application originally developed by Bosch Security (now part of Keenfinity). It integrates systems such as access control, video surveillance, fire detection, and intrusion monitoring.

In this project, BIS is the **application under test**. It depends on infrastructure commonly found in other enterprise applications: Windows services, web services, user authentication, SQL databases, network connectivity, and HTTPS certificates. The same diagnostic methods apply to many application-support and production-support roles, even when the software itself is different.

**Scope note:** This milestone covers the server application and its dependencies. The presence of BIS components does not mean physical security controllers, cameras, or external systems have been integrated.

## Skills Demonstrated So Far

| Area | Hands-on work completed |
|---|---|
| Windows Server & virtualization | Built and configured three Windows Server 2019 VMs using VMware Workstation. |
| Active Directory & DNS | Deployed a domain controller, organized computer accounts into OUs, and checked domain membership, DNS discovery, and secure channels. |
| SQL Server administration | Installed SQL Server 2019 Express with separate named database instances and dedicated storage on a remote database server. |
| Networking & diagnostics | Configured static IP addresses and isolated networking; verified DNS resolution and TCP connectivity between application and SQL servers. |
| HTTPS & reporting services | Configured remote SSRS and its certificate; successfully reached and authenticated to its HTTPS endpoints from the application server. |
| PowerShell & validation | Used repeatable commands and an AD baseline script to verify configuration and collect technical evidence. |

**Current focus:** Finish BIS post-installation checks and establish a verified, working baseline. **Next:** Add client testing, security hardening, monitoring, and controlled incident investigations.

## Current Status

**Current milestone: BIS 4.9.1 installed; post-installation validation in progress.**

- **Active Directory and DNS:** Deployed and baseline-validated on `DC01`.
- **SQL Server:** SQL Server 2019 Express installed on `SQL01` with separate named instances for BIS Event Log/Security Engine and Access Engine.
- **Reporting:** SSRS 2019 deployed on `SQL01`. HTTPS access from `BIS01` succeeded without certificate warnings, and a remote login using the local `SQL01` Administrator account succeeded. BIS service-account access and actual report execution remain unverified.
- **BIS application:** BIS 4.9.1 installed successfully on domain-joined `BIS01`; installation reported no errors and the server was rebooted.
- **Operational status:** **Not yet declared fully operational.** BIS service health, application database permissions, application-level reporting, licensing, initial configuration, client access, and final firewall rules still need validation or completion.

### Completed milestones

- Designed an isolated `10.10.10.0/24` network with no Internet-facing default gateway.
- Installed Windows Server 2019, Active Directory Domain Services, and DNS on `DC01`.
- Created `corp.bryanlab.test` and validated domain/forest and DNS service discovery.
- Created the planned OUs and Global Security Groups, and verified SYSVOL/NETLOGON availability.
- Recorded initial `dcdiag` warnings for a future troubleshooting exercise.
- Created a reusable [Active Directory baseline validation script](scripts/Test-ADBaseline.ps1).
- Built `SQL01` with a dedicated SQL data disk and joined it to the `Database-Servers` OU.
- Installed SQL Server 2019 Express with `SQL01\BIS` and `SQL01\BIS_ACE` as separate named instances.
- Installed and configured SSRS on `SQL01`; accessed reporting HTTPS endpoints locally.
- Completed remote SQL/SSRS preparation steps for BIS Topology 3, including creating a reporting certificate; imported the public certificate on `BIS01` and `DC01` (the need for trust on `DC01` will be reviewed).
- Built `BIS01` from a generalized Windows Server 2019 template, using a Basic disk with a 299.4 GiB C: volume.
- Joined `BIS01` to the `Application-Servers` OU and validated the secure channel and DomainAuthenticated network profile.
- Verified TCP reachability from `BIS01` to both SQL listeners, ports `14330` and `14331`.
- Completed BIS 4.9.1 application installation with the remote SQL and SSRS configuration; rebooted BIS01.
- Opened the remote SSRS HTTPS endpoints from BIS01 without certificate warnings and authenticated using the local SQL01 Administrator account.

## Current Active Directory Structure

```text
corp.bryanlab.test
|
+-- Domain Controllers
|   +-- DC01
|
+-- BRYANLAB-Servers
|   +-- Application-Servers
|   |   +-- BIS01
|   +-- Database-Servers
|       +-- SQL01
+-- BRYANLAB-Workstations
+-- BRYANLAB-Users
+-- BRYANLAB-Service-Accounts
+-- BRYANLAB-Groups
```

Initial security groups: `GG-BIS-Administrators`, `GG-BIS-Operators`, `GG-BIS-ReadOnly`, and `GG-SQL-Administrators`.

## Deployed Architecture

```text
              ISOLATED ENTERPRISE LAB
                  10.10.10.0/24

                         DC01
                    10.10.10.10
                     AD DS / DNS
                           |
                 +---------+---------+
                 |                   |
                 v                   v
              BIS01                 SQL01
           10.10.10.20           10.10.10.30
         Windows Server 2019   Windows Server 2019
           BIS 4.9.1            SQL Server 2019 Express
                 |                |          |
                 +--------------->| BIS      | BIS_ACE
                 |                | TCP 14330| TCP 14331
                 +--------------->| SSRS 2019 (HTTPS 443)

              CLIENT01: planned (10.10.10.40)
              No default gateway / no Internet access
```

BIS uses a remote database and remote reporting server (**Topology 3**, the vendor's name for this deployment arrangement). The **Access Engine (ACE)**, which supports access-control functionality, uses a separate named SQL Express instance from the BIS Event Log and Security Engine. This separation follows the BIS installation manual.

**BIS terminology:** *Event Log* records application events; *Security Engine* is a BIS functional component; *SSRS* is Microsoft SQL Server Reporting Services, used for reports. The architecture shown is **installed but not yet fully application-validated**.

## Technologies in Scope

**Used in the deployment:** Windows Server 2019, VMware Workstation, Active Directory Domain Services, DNS, PowerShell, SQL Server 2019 Express, SQL Server Reporting Services, BIS 4.9.1, HTTPS certificates, static network configuration, and connectivity diagnostics.

**Planned or still being validated:** Group Policy scenarios, firewall hardening, monitoring, performance and packet analysis, client deployment, incident simulation, and documented root-cause analysis.

## Validation and Evidence

Examples of checks used: `Get-ADDomain`, `Get-ADForest`, `Get-DnsServerZone`, `Resolve-DnsName`, `Get-ADComputer`, `Test-ComputerSecureChannel`, `Get-NetTCPConnection`, `Test-NetConnection`, and Windows storage commands.

- [AD baseline PowerShell script](scripts/Test-ADBaseline.ps1)
- [Latest archived AD baseline output](evidence/active-directory/outputs/Test-ADBaseline-output.txt)
- [Active Directory evidence](evidence/active-directory/)
- [SQL01 operating-system baseline evidence](evidence/sql-server/outputs/)
- [SQL listening ports](evidence/sql-server/outputs/SQL01-SQL-Listeners.txt)
- [BIS01 network, domain and storage evidence](evidence/bis-server/outputs/BIS01-Baseline-Validation.txt)
- [BIS01 remote SQL connectivity evidence](evidence/bis-server/outputs/BIS01-SQL-Connectivity.txt)
- [BIS installer configuration screenshot](evidence/bis-server/screenshots/BIS01-Installer-Configuration.png) — **pre-installation configuration**, not proof of runtime health

## Documentation

**New to this project?** Start with the [architecture overview](docs/architecture.md) for the big picture. The deployment documents show the implementation details, and the evidence links above show the checks actually performed.

- [Architecture and project roadmap](docs/architecture.md)
- [DC01 deployment and validation](docs/active-directory/dc01-deployment.md)
- [SQL01 Windows Server baseline (historical milestone)](docs/sql-server/sql01-deployment.md)
- [SQL01 SQL Server and SSRS deployment](docs/sql-server/sql01-sql-ssrs-deployment.md)
- [BIS01 deployment and post-installation checklist](docs/bis-server/bis01-deployment.md)

## Next Steps

- [ ] Review the BIS **Mandatory Post Installation** instructions.
- [ ] Run the BIS Change Password Tool as Administrator to change the `Mgts-SSRS-Viewer` password (Topology 3 requirement).
- [x] Import the SQL01 SSRS public certificate on BIS01 and test remote HTTPS authentication with an administrator account.
- [ ] Configure and test certificate trust on future BIS client machines; verify reporting under BIS application/service identities.
- [ ] Validate BIS Windows services, BIS Manager, both database connections, and reporting functionality.
- [ ] Complete licensing (if applicable), create an initial BIS configuration, and test client login.
- [ ] Re-enable Windows Firewall on all applicable systems and implement **vendor-documented, scoped rules**; validate connectivity again. The firewalls were temporarily disabled during installation in this isolated lab.
- [ ] Establish repeatable healthy-system checks and resource measurements (the main virtualization host has 32 GB RAM).
- [ ] Add CLIENT01, then implement monitoring, PowerShell automation, and controlled troubleshooting scenarios.

> **Project security:** Public documentation contains no passwords, license files or private certificate keys. Internal lab IP addresses and non-secret configuration names are shown for reproducibility.
