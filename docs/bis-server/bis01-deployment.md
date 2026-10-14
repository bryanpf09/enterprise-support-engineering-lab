# BIS01 — Building Integration System 4.9.1 Deployment

**Milestone:** BIS application installed against remote SQL Server and SSRS  
**Status:** Installation successful and reboot completed; operational validation pending

## Objective

Deploy **Bosch Building Integration System (BIS) 4.9.1** on a dedicated Windows Server 2019 VM integrated with Active Directory. Use a remote SQL Server 2019 Express and SQL Server Reporting Services environment (**BIS Topology 3**) to reproduce realistic enterprise application dependencies.

**Important distinction:** The BIS installation wizard completed without reported errors, and BIS01 was rebooted. This does **not yet establish a known-good operational baseline**. Runtime, licensing, database authentication, certificate trust, client access, and report execution are still being checked.

## BIS01 host configuration

| Property | Value / validation |
|---|---|
| Hostname | `BIS01` |
| OS | Windows Server 2019 (from generalized template) |
| Virtual resources | Planned 4 vCPUs and 16 GB RAM (verify actual allocation during baseline capture) |
| System disk | Basic disk; `C:` NTFS, 299.40 GiB total / 288.65 GiB free before BIS installation |
| IP / subnet | `10.10.10.20/24` |
| DNS | `10.10.10.10` (DC01) |
| Default gateway | None (isolated lab) |
| Active Directory | `corp.bryanlab.test` |
| Computer OU | `BRYANLAB-Servers/Application-Servers` |
| Network profile | `DomainAuthenticated` |
| Domain secure channel | `True` |
| Application directory | `C:\MgtS\` |

The original BIS01 clone was discarded during setup because its OS disk had been changed to Dynamic. A fresh clone was created and its **Basic** disk was extended instead. Windows storage verification reported the figures above. The final source VM template was not modified.

[Host baseline evidence](../../evidence/bis-server/outputs/BIS01-Baseline-Validation.txt)

## Active Directory integration

BIS01 was joined to the domain and its computer object was verified using Active Directory tools:

```text
Name              : BIS01
DNSHostName       : BIS01.corp.bryanlab.test
DistinguishedName : CN=BIS01,OU=Application-Servers,OU=BRYANLAB-Servers,DC=corp,DC=bryanlab,DC=test
NetworkCategory   : DomainAuthenticated
PartOfDomain      : True
SecureChannel     : True
```

Internal DNS discovery and LDAP connectivity to DC01 were tested successfully before the domain join.

## Remote SQL database topology

| BIS component | Remote SQL Server instance | Fixed TCP port |
|---|---|---|
| Event Log | `SQL01\BIS` | `14330` |
| Security Engine | `SQL01\BIS` | `14330` |
| Access Engine | `SQL01\BIS_ACE` | `14331` |
| Reporting Services | On `SQL01`, backed by `SQL01\BIS` | HTTPS `443` |

The Access Engine is on a **separate named SQL Express instance**, not merely a second database on the same instance. Both TCP listeners were validated on SQL01 and reached successfully from BIS01 before installation.

The installation wizard summary selected the login-server components **Access, Automation, Security, and Video**. Listed connector packages were installer selections; they are not evidence that physical controllers or third-party OPC systems have been deployed.

## BIS installation milestone

1. Built and domain-joined BIS01 on the isolated enterprise network.
2. Expanded the Basic OS partition to satisfy BIS 4.9.1's disk free-space requirement.
3. Prepared IIS/BIS installation prerequisites; independent IIS role/service evidence is still to be collected.
4. Prepared remote `SQL01` database instances and remote reporting infrastructure.
5. Checked network reachability of TCP `14330` and `14331` from BIS01.
6. Selected existing remote instances in the BIS 4.9.1 installer: `SQL01\BIS` for Event Log/Security Engine and SSRS; `SQL01\BIS_ACE` for Access Engine.
7. Reviewed the installer's final configuration summary (see screenshot).
8. Completed BIS application installation with **no errors reported**.
9. Rebooted BIS01 after installation.

[Installer summary screenshot (pre-installation)](../../evidence/bis-server/screenshots/BIS01-Installer-Configuration.png)

The screenshot records selected components and SQL destinations. It does **not** itself demonstrate successful completion or functioning application services.

## Mandatory post-installation tasks

The following items have **not been reported as completed** at the time of this milestone:

- [ ] Review and complete the BIS **Mandatory Post Installation** instructions displayed by the installer.
- [ ] On BIS01, run `C:\MgtS\Tools\ChangePassword` **as Administrator** and change the `Mgts-SSRS-Viewer` password, mandatory for Topology 3 (BIS 4.9.1 manual, page 19).
- [ ] Verify that BIS Windows services are installed, start as expected, and remain healthy after reboot.
- [ ] Open BIS Manager/Configuration Manager and check for system-level errors and database connectivity.
- [ ] Import the **public** SSRS self-signed `.CER` from SQL01 into the appropriate Local Machine trust store on BIS01, after verifying its identity/thumbprint (manual, section 8.3). Repeat on future client systems.
- [ ] Verify reporting HTTPS access **from BIS01**, then validate an actual report from the BIS application.
- [ ] Complete license configuration if required, then create and save an initial BIS configuration.
- [ ] Prepare a client system and validate authentication, BIS UI access, and a test workflow.
- [ ] Re-enable Windows Firewall and apply vendor-documented scoped rules on SQL01, BIS01, and DC01; repeat network/application checks.
- [ ] Capture application logs, Event Viewer events, services, and database/SSRS evidence as a healthy baseline.
- [ ] Monitor host memory usage: 32 GB physical RAM shared among several VMs.

## Suggested validation commands

Run these **after** post-installation steps, and review the outputs before marking the baseline complete:

```powershell
# Confirm Windows domain membership and secure channel
Get-CimInstance Win32_ComputerSystem | Select Name,Domain,PartOfDomain
Test-ComputerSecureChannel

# Reconfirm remote SQL TCP connectivity
Test-NetConnection SQL01.corp.bryanlab.test -Port 14330
Test-NetConnection SQL01.corp.bryanlab.test -Port 14331

# Discover BIS-related Windows services (names require verification)
Get-Service | Where-Object { $_.DisplayName -match 'BIS|Bosch|MgtS' } |
    Select Name,DisplayName,Status,StartType

# Confirm IIS server-role installation
Get-WindowsFeature Web-Server
```

Never export secrets or license information into public repository evidence.

## Evidence policy

Commands and screenshots are retained only when they document an actual observed state. Sensitive passwords, license files, private keys, and customer configurations are never committed. The deployment record distinguishes user-reported installer success from independently saved runtime evidence.

**Vendor reference:** BIS 4.9.1 Installation Manual, sections 3.1, 4.1–4.4, and 8.3; Topology 3 and required SSRS password change.
