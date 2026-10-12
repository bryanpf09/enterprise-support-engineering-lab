# SQL01 — Windows Server Deployment and Domain Integration

**Milestone:** SQL01 operating-system baseline  
**Status:** Completed and validated; SQL Server and SSRS installation pending

## Objective

Prepare a dedicated Windows Server 2019 VM to host Microsoft SQL Server and SQL Server Reporting Services (SSRS) for a future remote Keenfinity Building Integration System (BIS) deployment. Establish and verify the server's identity, storage, network configuration, and Active Directory integration before installing database software.

## Deployed configuration

| Component | Configuration |
|---|---|
| Hypervisor | VMware Workstation |
| Server name | `SQL01` |
| OS | Windows Server 2019 Standard Evaluation (version 1809, build 17763) |
| VM resources | 4 vCPUs, 8 GB RAM (configured) |
| OS disk | `C:` — 80 GB (configured) |
| Data disk | `D:` — 120 GiB NTFS, labeled `SQLData` |
| Data disk allocation unit | 64 KB (`65536` bytes) |
| Network adapter | `Ethernet0` |
| IP address | `10.10.10.30/24` |
| DNS server | `10.10.10.10` (`DC01`) |
| Default gateway | Not configured (intentional lab isolation) |
| AD domain | `corp.bryanlab.test` |
| Computer OU | `BRYANLAB-Servers/Database-Servers` |

The VM resource assignments and OS disk size were confirmed during deployment. The saved evidence files below independently capture the Windows OS identity, data volume, network configuration, and AD computer object.

## Deployment summary

1. Used a generalized Windows Server 2019 base VM as the clone source.
2. Configured SQL01's virtual CPU, memory, system disk, and separate data disk.
3. Completed initial Windows setup and assigned the hostname `SQL01`.
4. Initialized and formatted `D:` as NTFS with 64 KB allocation units; labeled the volume `SQLData`.
5. Connected the VM to the isolated `10.10.10.0/24` lab network, assigned a static address, and configured `DC01` for internal DNS resolution. No default gateway was configured.
6. Confirmed DNS domain-controller discovery and LDAP TCP connectivity to `DC01` during deployment.
7. Joined the VM to `corp.bryanlab.test`, targeting the `Database-Servers` OU.
8. Re-enabled Windows Firewall and verified that all three profiles were enabled.
9. Validated domain membership, the `DomainAuthenticated` network profile, the domain secure channel, and the SQL01 computer object's OU placement.

Windows Server Evaluation activation was completed separately, as reported during deployment; activation status is not included in the archived evidence files.

## Validation and evidence

| Check | Result | Evidence |
|---|---|---|
| Hostname and Windows edition/build | `SQL01`; Windows Server 2019 Standard Evaluation; build `17763` | [OS baseline](../../evidence/sql-server/outputs/SQL01-OS-Baseline.txt) |
| SQL data volume | `D:` labeled `SQLData`; NTFS; 64 KB cluster size | [Storage baseline](../../evidence/sql-server/outputs/SQL01-Storage-Baseline.txt) |
| Static network configuration | `10.10.10.30`; DNS `10.10.10.10`; no gateway | [Network baseline](../../evidence/sql-server/outputs/SQL01-Network-Baseline.txt) |
| Domain network identification | `DomainAuthenticated` | [Network baseline](../../evidence/sql-server/outputs/SQL01-Network-Baseline.txt) |
| Domain secure channel | `True` | [Network baseline](../../evidence/sql-server/outputs/SQL01-Network-Baseline.txt) |
| AD computer object | `SQL01.corp.bryanlab.test` in `Database-Servers` OU | [AD computer](../../evidence/sql-server/outputs/SQL01-AD-Computer.txt) |

Additional interactive checks completed during deployment (not archived separately): LDAP SRV lookup succeeded, TCP port 389 connectivity to DC01 succeeded, `PartOfDomain` returned `True`, and Windows Firewall profiles Domain/Private/Public reported enabled.

## Notes and outstanding work

- The two virtual disks provide logical separation of the OS and SQL data; they do not necessarily provide independent physical I/O performance.
- An ICMP test initially failed and succeeded after SQL01's firewall was temporarily disabled. The specific rule or cause was not established. The firewall was subsequently re-enabled and its profiles verified. DNS, LDAP, and the domain secure channel were functional.
- Physical host RAM is limited to 32 GB. Resource pressure must be reassessed when the 16 GB BIS01 VM is introduced, before collecting performance benchmarks.
- SQL Server 2019, SSRS, and BIS have **not** been installed at this milestone. Final SQL/SSRS installation settings will be selected after confirming the target BIS release's documentation and compatibility requirements.

## Next milestone

Select the BIS release and compatible SQL Server edition/configuration, then install and validate the SQL Server Database Engine and SSRS on `SQL01` before deploying `BIS01`.
