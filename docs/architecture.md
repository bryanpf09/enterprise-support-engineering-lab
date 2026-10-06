# Enterprise Support Engineering Lab — Architecture

**Document version:** 0.2  
**Project phase:** Phase 2 — Active Directory & DNS  
**Status:** In progress — AD/DNS baseline deployed and validated

## 1. Project Purpose

This project is a hands-on enterprise infrastructure and support-engineering lab built around Keenfinity Building Integration System (BIS).

The environment is designed to reproduce a realistic enterprise deployment while providing a controlled platform for refreshing and expanding skills in:

- Windows Server administration
- Active Directory
- DNS
- Group Policy
- Microsoft SQL Server
- SQL Server Reporting Services
- Enterprise application deployment
- Networking
- Firewalls and VPN
- Certificates and PKI
- Monitoring
- PowerShell and automation
- Performance analysis
- Packet analysis
- Incident troubleshooting
- Root-cause analysis

The environment will first be built as a known-good supported deployment. Performance constraints and failures will then be introduced deliberately and analyzed using structured troubleshooting methods.

---

## 2. Physical Environment

### Primary VMware Host

**Role:** Main virtualization host

**Hardware:**
- AMD Ryzen 9 processor
- 32 GB RAM
- Approximately 700 GB available storage
- VMware Workstation

**Current virtual machines:**
- DC01

**Planned virtual machines:**
- BIS01
- SQL01

### Secondary Lab Computer

**Hardware:**
- Intel Core i5-class processor
- 8 GB RAM

**Current role:**
- Reserved for future lab expansion

DC01 was originally planned for this system but was moved to the primary VMware host during implementation.

### Client Computer

**Role:** Physical enterprise client workstation

**Hardware:**
- Intel Core i5-class processor
- 8 GB RAM

**Initial role:**
- CLIENT01

This system will later also be used for remote-access and VPN testing.

---

## 3. Physical Network

The enterprise lab uses a dedicated physical Ethernet network that is isolated from the normal home network and the Internet.

### Lab Network

`10.10.10.0/24`

### Lab Network Equipment

```text
Management IP: 10.10.10.254
WAN connection: Disconnected
DHCP: Disabled
Internet access: None
```

The dedicated network device is initially used only to provide Ethernet connectivity between the physical lab systems.

### Physical Host Addresses

| Device | Address |
|---|---|
| Main VMware host | `10.10.10.101` |
| Secondary lab computer | `10.10.10.102` |
| Lab network device | `10.10.10.254` |

The physical hosts may independently use Wi-Fi for normal Internet access.

The Wi-Fi and lab Ethernet networks must not be bridged.

Windows Internet Connection Sharing must remain disabled.

---

## 4. Enterprise Lab Network

**Network:** `10.10.10.0/24`  
**Subnet mask:** `255.255.255.0`

There is initially **no default gateway**.

This intentionally prevents the lab systems from reaching the Internet.

### Addressing Plan

| System | IP Address | Function |
|---|---:|---|
| Future FW01 | `10.10.10.1` | Firewall / gateway / VPN |
| DC01 | `10.10.10.10` | Active Directory / DNS |
| BIS01 | `10.10.10.20` | BIS application server |
| SQL01 | `10.10.10.30` | SQL Server / SSRS |
| CLIENT01 | `10.10.10.40` | Enterprise client |
| Future MON01 | `10.10.10.50` | Monitoring / automation |
| Main physical host | `10.10.10.101` | VMware host |
| Secondary lab computer | `10.10.10.102` | Future lab expansion |
| Network device | `10.10.10.254` | Network management |

Addresses not currently assigned are reserved for future expansion.

---

## 5. Active Directory Design

### Active Directory DNS Domain

`corp.bryanlab.test`

### NetBIOS Domain

`BRYANLAB`

### Initial Domain Controller

`DC01`

DC01 currently provides:

- Active Directory Domain Services
- DNS
- Domain authentication
- Group Policy support

DHCP may be introduced later as an additional Windows Server service.

Domain-joined systems will use:

`Preferred DNS: 10.10.10.10`

No Internet DNS forwarding is required during the initial isolated deployment.

### Current Active Directory Implementation

The initial Active Directory structure has been created and validated.

Current organizational units include:

- `BRYANLAB-Servers`
  - `Application-Servers`
  - `Database-Servers`
- `BRYANLAB-Workstations`
- `BRYANLAB-Users`
- `BRYANLAB-Service-Accounts`
- `BRYANLAB-Groups`

Initial Global Security Groups include:

- `GG-BIS-Administrators`
- `GG-BIS-Operators`
- `GG-BIS-ReadOnly`
- `GG-SQL-Administrators`

---

## 6. Server Roles

### DC01

**Operating system:** Windows Server 2019

**Roles:**
- Active Directory Domain Services
- DNS
- Group Policy infrastructure

### BIS01

**Operating system:** Windows Server 2019

**Roles:**
- Keenfinity Building Integration System
- BIS application/login server
- BIS-related application services

BIS01 will use a remote SQL Server rather than a locally installed production database.

### SQL01

**Operating system:** Windows Server 2019

**Roles:**
- Microsoft SQL Server 2019
- SQL Server Reporting Services
- BIS databases
- Reporting databases

SQL01 will be separate from BIS01 to reproduce an enterprise remote-database architecture.

### CLIENT01

**Platform:** Physical Windows workstation

**Roles:**
- Domain member
- BIS client
- Enterprise user workstation
- Testing workstation
- Future VPN client
- Future packet-analysis workstation

### FW01 — Future

**Roles:**
- Network firewall
- Routing
- Controlled Internet access
- VPN termination
- Network segmentation

FW01 will eventually become the lab's default gateway.

### MON01 — Future

**Roles:**
- Infrastructure monitoring
- Automation
- Health checking
- Future Linux administration exercises

---

## 7. Initial Resource Allocation

Resource assignments are provisional until the exact BIS release and its requirements are finalized.

### BIS01

```text
vCPU: 4
RAM: 16 GB baseline target
Storage: approximately 120 GB initially
```

### SQL01

```text
vCPU: 4
RAM: approximately 8 GB initially
Storage: approximately 180–200 GB initially
```

### DC01

```text
vCPU: 2
RAM: approximately 3–4 GB
Storage: approximately 60 GB
```

Resource utilization on the physical VMware hosts will be monitored to ensure host resource pressure does not invalidate application performance testing.

---

## 8. Software Baseline

Current planned baseline:

```text
Server OS: Windows Server 2019
Database platform: Microsoft SQL Server 2019
Reporting: SQL Server Reporting Services
Enterprise application: Keenfinity Building Integration System
```

The exact BIS release will be finalized after reviewing the version-specific release letter, installation documentation, system requirements, and compatibility information from the official Keenfinity Download Store.

Candidate BIS versions currently available for the lab include:

```text
BIS 4.9.1
BIS 5.0
BIS 6.0
```

---

## 9. Network Isolation

During the initial deployment:

```text
DC01      → Internet: BLOCKED
BIS01     → Internet: BLOCKED
SQL01     → Internet: BLOCKED
CLIENT01  → Internet: BLOCKED
```

No system will initially have a default gateway.

Installation files and other required software will be obtained separately and transferred into the isolated environment.

Controlled outbound access may later be introduced through FW01.

---

## 10. Build Philosophy

The project follows a controlled engineering approach.

### Stage 1 — Supported Baseline

All components will first be installed and configured using supported hardware and software configurations.

The environment must operate correctly before intentional failures or resource restrictions are introduced.

### Stage 2 — Baseline Measurements

Performance and behavior will be documented while the environment is healthy.

Potential measurements include:

- Server startup
- Service startup
- BIS client login
- Application responsiveness
- SQL responsiveness
- Report generation
- CPU usage
- Memory utilization
- Paging
- Disk performance
- Network behavior

### Stage 3 — Controlled Resource Constraints

Resources may then be reduced intentionally.

Examples:

```text
Memory reduction
CPU reduction
Storage-performance constraints
```

Only one major variable should be changed at a time whenever possible.

### Stage 4 — Failure Injection

After the complete environment is stable, failures will deliberately be introduced.

Examples include:

- DNS failure
- SQL connectivity failure
- Blocked network ports
- Service failures
- Active Directory account problems
- Permission problems
- Group Policy problems
- Certificate failures
- SSRS failures
- VPN problems
- Resource exhaustion

### Stage 5 — Troubleshooting and Root-Cause Analysis

Each failure scenario will be documented using:

```text
Incident
Symptoms
Impact
Initial hypotheses
Diagnostic process
Evidence
Root cause
Resolution
Validation
Preventive recommendation
Lessons learned
```

Diagnostic tools may include:

- Windows Event Viewer
- PowerShell
- Performance Monitor
- Resource Monitor
- SQL Server logs
- BIS logs
- SSRS logs
- IIS logs
- DNS tools
- Network troubleshooting tools
- Wireshark

---

## 11. Project Phases

```text
Phase 0   Architecture & Design — Completed
Phase 1   Virtual Infrastructure — In progress
Phase 2   Active Directory & DNS — In progress
Phase 3   SQL Server & Reporting Services — Planned
Phase 4   BIS Deployment — Planned
Phase 5   Client & Identity Integration — Planned
Phase 6   Certificates / PKI — Planned
Phase 7   Network Segmentation & Firewall — Planned
Phase 8   Monitoring & Automation — Planned
Phase 9   Remote Access / VPN — Planned
Phase 10  Supported Baseline & Performance Testing — Planned
Phase 11  Failure Injection & Troubleshooting — Planned
```

---

## 12. Target Architecture

```text
                 ISOLATED ENTERPRISE LAB
                       10.10.10.0/24

                           DC01
                      10.10.10.10
                      AD DS / DNS
                           │
              ┌────────────┼────────────┐
              │            │            │
              ▼            ▼            ▼

            BIS01        SQL01       CLIENT01
         10.10.10.20   10.10.10.30  10.10.10.40
              │            │
              │       SQL Server 2019
              │            +
              │           SSRS
              │            │
              └────────────┘
               BIS ↔ SQL/SSRS

                  No Internet access
                  No default gateway


Future:

                        FW01
                     Firewall/VPN
                         │
                ┌────────┴────────┐
                │                 │
         Enterprise Network   Remote/VPN
                │                 │
       DC01/BIS01/SQL01       CLIENT01
```

---

## 13. Documentation Principle

All architecture changes, configuration decisions, experiments, failures, troubleshooting procedures, and findings should be documented throughout the project.

The objective is not only to make the environment work, but to demonstrate repeatable enterprise support-engineering methodology.
