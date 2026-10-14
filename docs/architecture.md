# Enterprise Support Engineering Lab — Architecture

**Document version:** 0.3  
**Project phase:** Phase 4 — BIS deployment and post-installation validation  
**Status:** BIS 4.9.1 installed; end-to-end operational validation in progress

## 1. Project Purpose

This hands-on enterprise infrastructure and support-engineering lab is built around **Building Integration System (BIS)**, now part of Keenfinity (formerly Bosch Security), and its Windows Server, Active Directory, SQL Server, reporting, and networking dependencies.

The project is designed to document a realistic multi-server deployment, validate a known-good operating baseline, and then reproduce controlled incidents using structured troubleshooting and root-cause analysis.

Scope includes Windows Server, Active Directory/DNS, Group Policy, SQL Server 2019, SSRS, BIS, certificates/PKI, network/firewall configuration, monitoring, PowerShell, performance and packet analysis, and incident response.

**Milestone distinction:** Successful software installation is not equivalent to a verified operational baseline. BIS runtime, database authorization, reporting, certificate trust, licensing and client access still require checks.

---

## 2. Physical Environment

### Primary VMware Host

- Processor: AMD Ryzen 9 family
- RAM: 32 GB
- Approximately 700 GB available storage at initial planning (not a current free-space measurement)
- Hypervisor: VMware Workstation
- **Deployed VMs:** `DC01`, `SQL01`, `BIS01`

Resource contention is a significant consideration: BIS01 is targeted for 16 GB RAM, SQL01 uses 8 GB, and DC01 approximately 3–4 GB, leaving limited RAM for the physical host when all are running. Actual allocation and host utilization will be captured before performance baselining.

### Secondary Lab Computer

- Intel Core i5-class CPU; 8 GB RAM
- Reserved for additional lab tasks. DC01 was initially planned for this system but moved to the primary host during deployment.

### Client Computer

- Intel Core i5-class CPU; 8 GB RAM
- Planned role: physical `CLIENT01` workstation for BIS clients, domain integration, network diagnostics, and later VPN testing.

---

## 3. Physical Network

The enterprise lab uses a dedicated Ethernet segment isolated from the home network and the Internet.

**Network:** `10.10.10.0/24`  
**Physical lab network equipment:** `10.10.10.254`  
**WAN:** Disconnected  
**DHCP:** Disabled

| Device | Address | Role |
|---|---|---|
| Main VMware host | `10.10.10.101` | Virtualization |
| Secondary lab computer | `10.10.10.102` | Future expansion |
| Dedicated network device | `10.10.10.254` | Lab Ethernet networking |

The physical hosts can independently use Wi-Fi for regular Internet access. Wi-Fi and lab Ethernet **must not be bridged**, and Windows Internet Connection Sharing must remain disabled.

---

## 4. Enterprise Lab Network

**Subnet:** `10.10.10.0/24`  
**Subnet mask:** `255.255.255.0`  
**Default gateway:** None  
**Internal DNS:** `10.10.10.10`

| System | IP address | Purpose | State |
|---|---|---|---|
| DC01 | `10.10.10.10` | AD DS, DNS | Deployed |
| BIS01 | `10.10.10.20` | BIS 4.9.1 application/login server | Installed; validation in progress |
| SQL01 | `10.10.10.30` | SQL Server 2019 Express, SSRS | Installed; validation in progress |
| CLIENT01 | `10.10.10.40` | Enterprise BIS client | Planned |
| Future MON01 | `10.10.10.50` | Monitoring and automation | Planned |
| Future FW01 | `10.10.10.1` | Routing, firewall, VPN | Planned |
| VMware host | `10.10.10.101` | Hypervisor | In use |
| Secondary lab computer | `10.10.10.102` | Lab expansion | Available |
| Lab network device | `10.10.10.254` | Ethernet network | In use |

The lack of a default gateway intentionally keeps lab systems away from the Internet. Installation software is transferred into the isolated environment separately.

---

## 5. Active Directory Design

**AD DNS domain:** `corp.bryanlab.test`  
**NetBIOS domain:** `BRYANLAB`  
**Domain controller/DNS server:** `DC01` at `10.10.10.10`

The initial Active Directory baseline was deployed and validated. The OU structure includes:

```text
corp.bryanlab.test
|
+-- Domain Controllers
|   +-- DC01
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

Initial Global Security Groups:

- `GG-BIS-Administrators`
- `GG-BIS-Operators`
- `GG-BIS-ReadOnly`
- `GG-SQL-Administrators`

Domain discovery, DNS SRV resolution, domain membership, secure channels, and computer OU placement have been verified at the relevant milestones. Historical `dcdiag` warnings remain documented for later investigation. DHCP may be introduced in a future phase.

---

## 6. Deployed Server Roles

### DC01 — Directory and DNS

- Windows Server 2019
- Active Directory Domain Services, DNS, Group Policy infrastructure
- Domain `corp.bryanlab.test`
- Baseline validated; further health monitoring and security-hardening work planned

### SQL01 — Databases and reporting

- Windows Server 2019, domain-joined under `Database-Servers`
- 4 vCPUs, 8 GB RAM
- Operating-system C: volume (~80 GB) and dedicated D: `SQLData` volume (120 GiB NTFS, 64 KB allocation units)
- SQL Server **2019 Express**, installed as two named instances:
  - `SQL01\BIS` (Event Log/Security Engine) — static TCP **14330**
  - `SQL01\BIS_ACE` (Access Engine) — static TCP **14331**
- SQL Server Reporting Services 2019 on SQL01, HTTPS **443**, with reporting database on the `BIS` instance
- Local reporting service endpoints and both SQL listeners checked; BIS-to-SQL TCP reachability verified
- End-to-end reporting, SQL permissions, and firewall hardening still pending

A separate Access Engine instance is required because BIS 4.9.1 documents ACE and Event Log/Security Engine on the same SQL Server Express instance as incompatible.

### BIS01 — Enterprise application

- Windows Server 2019, domain-joined under `Application-Servers`
- Target resources: 4 vCPUs and 16 GB RAM (confirm allocation during the final host baseline)
- **Basic disk** expanded to 300 GB virtual capacity; pre-installation C: verification: **299.40 GiB total / 288.65 GiB free**
- Static IP `10.10.10.20`; AD domain secure channel and `DomainAuthenticated` network status verified
- **BIS 4.9.1** installation completed without reported errors; reboot performed
- BIS installed at `C:\MgtS\`
- BIS installer configured the Access, Automation, Security, and Video login-server components
- Uses SQL01 for both SQL instances and SSRS (**Topology 3**)
- BIS runtime health, licensing, initial configuration, reporting certificate trust and client tests pending

### CLIENT01 — Planned client

- Physical Windows workstation to be domain-joined
- BIS Classic/Smart client testing, test reporting, network/packet captures and future VPN scenarios

### FW01 — Future firewall/VPN

- Controlled routing, firewall filtering, network segmentation and remote-access VPN

### MON01 — Future monitoring/automation

- Infrastructure monitoring, PowerShell automation, Linux exercises and automated health checks

---

## 7. Database and Reporting Topology

BIS 4.9.1 installation follows the vendor's **Topology 3**: the BIS login server runs separately from both SQL Server databases and Reporting Services.

```text
                     ISOLATED LAB / 10.10.10.0/24

                           DC01
                       10.10.10.10
                        AD DS / DNS
                            |
                +-----------+-----------+
                |                       |
                v                       v
              BIS01                   SQL01
           10.10.10.20             10.10.10.30
           BIS 4.9.1       SQL Server 2019 Express + SSRS
                |                       |
                +----- Event Log ------> SQL01\BIS     (TCP 14330)
                +----- Security Engine -> SQL01\BIS     (TCP 14330)
                +----- Access Engine --> SQL01\BIS_ACE (TCP 14331)
                +----- Reporting ------> SSRS HTTPS     (TCP 443)

                    CLIENT01 (future): 10.10.10.40
                   No Internet access / no gateway
```

SSRS endpoints verified locally on SQL01:

```text
https://sql01:443/ReportServer_BIS
https://sql01:443/Reports_BIS
```

SSRS uses a self-signed reporting certificate. Distribution of the **public** certificate to BIS01 and future client systems is pending. The certificate's identity and trust must be checked; private keys must not be copied into the repository.

---

## 8. Software Baseline

| Component | Installed version / state |
|---|---|
| Server operating systems | Windows Server 2019 |
| BIS | 4.9.1, installed on BIS01 |
| SQL Server | SQL Server 2019 Express, named instances BIS and BIS_ACE |
| Reporting Services | SSRS 2019 on SQL01 |
| Hypervisor | VMware Workstation |
| Domain services | AD DS and DNS on DC01 |

Software installation has been reported successful, but the whole-system baseline **will only be marked healthy after application, database, reporting, client and security validation**.

---

## 9. Security and Network Isolation

The initial build is offline and has no default gateway. Windows Firewall was temporarily disabled on DC01, SQL01 and BIS01 during the vendor installation workflow. This is a **temporary deployment condition**, not the target baseline.

Pending actions:

- Restore and validate enabled Windows Firewall profiles, including on DC01.
- Configure scoped rules for vendor-required services and authorized source hosts.
- Retest ports `14330` and `14331` after SQL01 firewall configuration and validate SSRS HTTPS 443.
- Review additional BIS application ports using the vendor-supplied `BIS_Firewall_Configuration.pdf` rather than guessing.
- Verify certificate trust, account rights, reporting credentials, and domain protections.
- Keep passwords, private keys, licenses, and personal/customer details out of GitHub.

---

## 10. Build and Validation Philosophy

### Stage 1 — Supported deployment (current)

Install Windows Server, Active Directory, SQL Server, SSRS and BIS according to the chosen version-specific documentation. BIS installation is complete; **post-installation steps and baseline validation remain underway**.

### Stage 2 — Healthy baseline measurements

Measure server/service startup, BIS login, database/report response, CPU, memory, paging, storage, network behavior and event/application logs, with a stable application configuration.

### Stage 3 — Controlled constraints

Intentionally introduce one variable at a time (for example RAM, CPU or storage performance constraints), then capture symptoms, evidence and recovery.

### Stage 4 — Failure injection

Representative scenarios: DNS lookup failure, domain authentication/permissions, blocked SQL ports, service outages, SSRS certificate trust, SQL connectivity, IIS/BIS service failures, GPO misconfiguration, disk or memory pressure, and VPN issues.

### Stage 5 — Root-cause analysis

Use a repeatable incident template: **incident, symptoms, impact, initial hypotheses, diagnostics, evidence, root cause, resolution, validation, prevention and lessons learned**.

Diagnostic tools may include Windows Event Viewer, SQL/BIS/SSRS/IIS logs, PowerShell, Resource Monitor, Performance Monitor, `Test-NetConnection`, DNS utilities and Wireshark.

---

## 11. Project Phases

| Phase | Description | Current status |
|---|---|---|
| 0 | Architecture and design | Initial design complete; maintained as deployment evolves |
| 1 | Virtual infrastructure | Core server VMs deployed |
| 2 | Active Directory and DNS | Baseline deployed and validated |
| 3 | SQL Server and Reporting Services | Installed; integration and reporting validation pending |
| 4 | BIS deployment | Installed and rebooted; mandatory post-install tasks pending |
| 5 | Client and identity integration | Planned |
| 6 | Certificates and PKI | Initial reporting certificate configured; BIS01/client trust pending |
| 7 | Network firewall and segmentation | Firewall hardening pending; future segmentation planned |
| 8 | Monitoring and automation | AD validation script exists; further expansion planned |
| 9 | Remote access and VPN | Planned |
| 10 | Supported baseline and performance testing | Pending complete operational validation |
| 11 | Failure injection and troubleshooting | Planned |

---

## 12. Next Milestones

1. Review BIS Mandatory Post Installation requirements and change the Topology 3 `Mgts-SSRS-Viewer` password using the vendor tool.
2. Validate Windows services, BIS Manager, application logs, SQL access and the SSRS end-to-end reporting workflow.
3. Import and validate the public SSRS certificate on BIS01 and clients.
4. License and configure BIS as required, then test a complete client workflow.
5. Re-enable scoped firewall protections and repeat connectivity and functional tests.
6. Capture the known-good baseline and resource metrics before controlled troubleshooting experiments.
7. Bring CLIENT01 online and expand PowerShell, certificate, monitoring and VPN scenarios.

---

## 13. Documentation Principle

Architecture decisions, configuration changes, verified command output, deployment issues, troubleshooting and lessons learned are documented continuously.

**Integrity of evidence matters:** distinguish screenshot/command results from assumptions, and installation success from proof of operational health. This repository must not contain passwords, private certificate keys, production customer data, or vendor licenses.

Supporting records: [SQL01 application deployment](sql-server/sql01-sql-ssrs-deployment.md), [BIS01 deployment](bis-server/bis01-deployment.md), and [DC01 validation](active-directory/dc01-deployment.md).
