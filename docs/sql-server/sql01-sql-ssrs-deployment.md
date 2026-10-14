# SQL01 — SQL Server 2019 and Remote Reporting Services Deployment

**Milestone:** Database and reporting infrastructure for BIS 4.9.1  
**Status:** Installed; end-to-end application and reporting validation pending

## Objective

Deploy Microsoft SQL Server 2019 Express and SQL Server Reporting Services (SSRS) on a separate Windows Server 2019 domain member to support Building Integration System (BIS) 4.9.1. This follows the installation manual's **Topology 3**, with both database services and Reporting Services on the remote SQL server.

The earlier [SQL01 Windows Server baseline](sql01-deployment.md) intentionally records the *pre-SQL-installation* stage; this document records the later application deployment.

## SQL01 platform

| Component | Configuration |
|---|---|
| Hostname / IP | `SQL01` / `10.10.10.30` |
| Windows / domain | Windows Server 2019 / `corp.bryanlab.test` |
| Virtual resources | 4 vCPUs, 8 GB RAM |
| SQL storage | Dedicated `D:` volume, NTFS, `SQLData` |
| SQL version | SQL Server 2019 Express |
| Reporting | SQL Server Reporting Services 2019 |
| Network | Isolated `10.10.10.0/24`; no default gateway |

## Database Engine deployment

BIS Event Log and Security Engine use `SQL01\BIS`. BIS Access Engine (ACE) uses a **separate SQL instance**, `SQL01\BIS_ACE`.

This is required for SQL Server Express: the BIS 4.9.1 manual states that ACE and Event Log/Security Engine may not share the same SQL Server Express instance.

| Setting | BIS instance | BIS_ACE instance |
|---|---|---|
| Named instance | `BIS` | `BIS_ACE` |
| Fixed TCP port | `14330` | `14331` |
| Authentication | Mixed Mode | Mixed Mode |
| Features | Database Engine, Full-Text | Database Engine, Full-Text |
| Max server memory | 1410 MB | 1410 MB |
| User database data | `D:\SQLData\Data` | `D:\SQLData\BIS_ACE\Data` |
| User database logs | `D:\SQLData\Logs` | `D:\SQLData\BIS_ACE\Logs` |
| Backups | `D:\SQLData\Backups` | `D:\SQLData\BIS_ACE\Backups` |
| TempDB | `D:\SQLData\TempDB` | `D:\SQLData\BIS_ACE\TempDB` |

Both instances were created using the SQL Server 2019 GUI installer. TCP/IP and Named Pipes were enabled, and the SQL Server Browser was configured for automatic startup. FILESTREAM was left disabled. User Instances were enabled during setup; whether to retain this setting will be revisited during hardening.

The ACE instance's initial TempDB settings used one 64 MB data file, a 64 MB log file, and 64 MB growth increments. These are lab setup values, not a production tuning recommendation.

SQL Server `max server memory` does not restrict all SQL Server process allocations, and SSRS uses additional memory. SQL01 memory pressure must be measured once BIS is running normally.

## Reporting Services deployment

SSRS 2019 was installed on SQL01 and associated with the `SQL01\BIS` database engine.

| Property | Configuration |
|---|---|
| SSRS service | `SQLServerReportingServices` |
| Reporting database | `ReportServer$BIS` |
| SSRS Web Service | `https://sql01:443/ReportServer_BIS` |
| SSRS Web Portal | `https://sql01:443/Reports_BIS` |

The SSRS service was confirmed running, and both HTTPS endpoints were reached **from SQL01 itself**. The remote SQL preparation utilities supplied with BIS installation media were run, and an SSRS self-signed certificate was configured. The public `.CER` was prepared for import on BIS01 and subsequent clients; remote trust testing is pending.

## Verified SQL network connectivity

SQL01's TCP listening checks returned:

```text
0.0.0.0    14330  Listen
0.0.0.0    14331  Listen
::         14330  Listen
::         14331  Listen
```

From `BIS01` (`10.10.10.20`), `Test-NetConnection` resolved `SQL01.corp.bryanlab.test` to `10.10.10.30` and returned `TcpTestSucceeded : True` for ports `14330` and `14331`.

[Listener evidence](../../evidence/sql-server/outputs/SQL01-SQL-Listeners.txt) · [Remote reachability evidence](../../evidence/bis/outputs/BIS01-SQL-Connectivity.txt)

These tests prove TCP accessibility, not SQL login authorization, query execution, or end-to-end BIS operation.

## Post-installation security work

Windows Firewall was temporarily disabled during installation on the isolated lab network. Restoration and validation of least-privilege inbound rules are **pending**. Known fixed SQL TCP ports are `14330` and `14331`; additional required BIS/SSRS/Windows ports will be reviewed against the vendor firewall configuration guide. Do not publish passwords, certificate private keys, or license material.

## Pending validation

- [ ] Confirm BIS can authenticate to both SQL instances and query its application databases.
- [ ] Import/verify remote SSRS certificate trust on BIS01 and clients.
- [ ] Confirm reports deploy and execute successfully from BIS.
- [ ] Re-enable and configure Windows Firewall, then retest SQL and SSRS connectivity.
- [ ] Capture sanitized database, reporting, service and application evidence.
- [ ] Monitor resources while both SQL instances and SSRS are active.

**Vendor reference:** BIS 4.9.1 Installation Manual, sections 4.2.1–4.2.5 and 4.3; Topology 3 and separate ACE instance guidance.
