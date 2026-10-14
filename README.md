# Enterprise Support Engineering Lab

Hands-on enterprise infrastructure and troubleshooting lab built around Windows Server, Active Directory, DNS, SQL Server, networking, automation, and Keenfinity (formerly Bosch Security) **Building Integration System (BIS)**.

The goal is to build a realistic enterprise environment, validate a known-good baseline, and later introduce controlled failures for structured troubleshooting and root-cause analysis.

## Current Status

**Current milestone: BIS 4.9.1 installed; post-installation validation in progress.**

- **Active Directory and DNS:** Deployed and baseline-validated on `DC01`.
- **SQL Server:** SQL Server 2019 Express installed on `SQL01` with separate named instances for BIS Event Log/Security Engine and Access Engine.
- **Reporting:** SSRS 2019 deployed on `SQL01`; local HTTPS endpoints validated. Remote trust and report execution are pending.
- **BIS application:** BIS 4.9.1 installed successfully on domain-joined `BIS01`; installation reported no errors and the server was rebooted.
- **Operational status:** **Not yet declared fully operational.** Service health, database authentication, reporting, licensing, first configuration, certificate trust, and final firewall rules still need validation or completion.

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
- Completed remote SQL/SSRS preparation steps for BIS Topology 3, including preparing a public reporting certificate for later client trust configuration.
- Built `BIS01` from a generalized Windows Server 2019 template, using a Basic disk with a 299.4 GiB C: volume.
- Joined `BIS01` to the `Application-Servers` OU and validated the secure channel and DomainAuthenticated network profile.
- Verified TCP reachability from `BIS01` to both SQL listeners, ports `14330` and `14331`.
- Completed BIS 4.9.1 application installation with the remote SQL and SSRS configuration; rebooted BIS01.

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

BIS uses a remote database and remote SSRS server (**BIS 4.9.1 Topology 3**). ACE runs on a separate named SQL Express instance, as required by the installation manual. The architecture shown is **installed but not yet fully application-validated**.

## Technologies in Scope

Windows Server 2019, Active Directory Domain Services, DNS, Group Policy, PowerShell, VMware Workstation, SQL Server 2019 Express, SQL Server Reporting Services, BIS 4.9.1, HTTPS certificates/PKI, network troubleshooting, firewall configuration, monitoring, performance analysis, packet analysis, incident troubleshooting and root-cause analysis.

## Validation and Evidence

Examples of checks used: `Get-ADDomain`, `Get-ADForest`, `Get-DnsServerZone`, `Resolve-DnsName`, `Get-ADComputer`, `Test-ComputerSecureChannel`, `Get-NetTCPConnection`, `Test-NetConnection`, and Windows storage commands.

- [AD baseline PowerShell script](scripts/Test-ADBaseline.ps1)
- [Latest archived AD baseline output](evidence/active-directory/outputs/Test-ADBaseline-output.txt)
- [Active Directory evidence](evidence/active-directory/)
- [SQL01 operating-system baseline evidence](evidence/sql-server/outputs/)
- [SQL listening ports](evidence/sql-server/outputs/SQL01-SQL-Listeners.txt)
- [BIS01 network, domain and storage evidence](evidence/bis/outputs/BIS01-Baseline-Validation.txt)
- [BIS01 remote SQL connectivity evidence](evidence/bis/outputs/BIS01-SQL-Connectivity.txt)
- [BIS installer configuration screenshot](evidence/bis/screenshots/BIS01-Installer-Configuration.png) — **pre-installation configuration**, not proof of runtime health

## Documentation

- [Architecture and project roadmap](docs/architecture.md)
- [DC01 deployment and validation](docs/active-directory/dc01-deployment.md)
- [SQL01 Windows Server baseline (historical milestone)](docs/sql-server/sql01-deployment.md)
- [SQL01 SQL Server and SSRS deployment](docs/sql-server/sql01-sql-ssrs-deployment.md)
- [BIS01 deployment and post-installation checklist](docs/bis/bis01-deployment.md)

## Next Steps

- [ ] Review the BIS **Mandatory Post Installation** instructions.
- [ ] Run the BIS Change Password Tool as Administrator to change the `Mgts-SSRS-Viewer` password (Topology 3 requirement).
- [ ] Import and verify the SQL01 SSRS public certificate on BIS01 and later on BIS clients.
- [ ] Validate BIS Windows services, BIS Manager, both database connections, and reporting functionality.
- [ ] Complete licensing (if applicable), create an initial BIS configuration, and test client login.
- [ ] Re-enable Windows Firewall on all applicable systems and implement **vendor-documented, scoped rules**; validate connectivity again. The firewalls were temporarily disabled during installation in this isolated lab.
- [ ] Establish repeatable healthy-system checks and resource measurements (the main virtualization host has 32 GB RAM).
- [ ] Add CLIENT01, then implement monitoring, PowerShell automation, and controlled troubleshooting scenarios.

> **Project security:** Public documentation contains no passwords, license files or private certificate keys. Internal lab IP addresses and non-secret configuration names are shown for reproducibility.
