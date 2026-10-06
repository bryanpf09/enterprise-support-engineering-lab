# Enterprise Support Engineering Lab

Hands-on enterprise infrastructure and troubleshooting lab built around Windows Server, Active Directory, DNS, SQL Server, networking, automation, and Keenfinity Building Integration System (BIS).

The goal of this project is to build a realistic enterprise environment, validate it as a known-good baseline, and later introduce controlled failures for troubleshooting and root-cause analysis.

## Current Status

The project is currently in the Active Directory and DNS phase.

Completed so far:

- Designed an isolated enterprise lab network using `10.10.10.0/24`
- Deployed `DC01` on Windows Server 2019
- Installed and configured Active Directory Domain Services and DNS
- Created the `corp.bryanlab.test` forest
- Configured static addressing and internal DNS
- Validated domain and forest configuration with PowerShell
- Verified LDAP SRV record resolution and domain-controller discovery
- Validated SYSVOL and NETLOGON availability
- Created an organizational-unit structure for servers, workstations, users, service accounts, and groups
- Created Global Security Groups for planned BIS and SQL access roles
- Collected screenshots and command output as deployment evidence
- Documented post-deployment `dcdiag` findings for later troubleshooting

## Current Active Directory Structure

```text
corp.bryanlab.test
│
├── Domain Controllers
│   └── DC01
│
├── BRYANLAB-Servers
│   ├── Application-Servers
│   └── Database-Servers
│
├── BRYANLAB-Workstations
├── BRYANLAB-Users
├── BRYANLAB-Service-Accounts
└── BRYANLAB-Groups

```

Initial security groups:

```text
GG-BIS-Administrators
GG-BIS-Operators
GG-BIS-ReadOnly
GG-SQL-Administrators
```

## Planned Architecture

```text
                    ISOLATED LAB
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
                        │
                  SQL Server 2019
                        +
                       SSRS
```

The initial environment intentionally has no default gateway and no Internet access.

## Technologies in Scope

- Windows Server 2019
- Active Directory Domain Services
- DNS
- Group Policy
- PowerShell
- VMware Workstation
- Microsoft SQL Server
- SQL Server Reporting Services
- Enterprise application deployment
- Network troubleshooting
- Certificates and PKI
- Firewall and VPN concepts
- Monitoring
- Performance analysis
- Packet analysis
- Incident troubleshooting
- Root-cause analysis

## Validation and Evidence

Configuration is validated with both Windows administration tools and PowerShell.

Examples include:

- `Get-ADDomain`
- `Get-ADForest`
- `Get-DnsServerZone`
- `Get-ADOrganizationalUnit`
- `Get-ADGroup`
- `Resolve-DnsName`
- `dcdiag`
- `ipconfig /all`

Supporting command output and screenshots:

[Active Directory evidence](evidence/active-directory/)

## Documentation

- [Lab architecture](docs/architecture.md)
- [DC01 deployment and validation](docs/active-directory/dc01-deployment.md)

## Next Steps

- Continue Active Directory identity configuration
- Deploy `SQL01`
- Install SQL Server 2019 and SSRS
- Deploy `BIS01`
- Integrate BIS with the remote SQL Server
- Join the client workstation to the domain
- Add Group Policy and certificate scenarios
- Introduce monitoring and PowerShell automation
- Begin controlled failure-injection and troubleshooting exercises