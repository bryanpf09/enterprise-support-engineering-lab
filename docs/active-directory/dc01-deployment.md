# DC01 Deployment

## Objective
Deploy the first domain controller for the isolated enterprise lab.

## Initial Configuration
- OS: Windows Server 2019
- Hostname: DC01
- IP: 10.10.10.10/24
- Default gateway: none
- DNS: 10.10.10.10
- Domain: corp.bryanlab.test
- NetBIOS: BRYANLAB

## Deployment Steps
1. Cloned the Windows Server 2019 base VM.
2. Ran Sysprep to generalize the clone.
3. Configured the hostname and static IP address.
4. Installed Active Directory Domain Services and DNS.
5. Created a new forest: corp.bryanlab.test.
6. Promoted DC01 to domain controller.

## Validation
Validation included:
- Get-ADDomain
- Get-ADForest
- Get-DnsServerZone
- Resolve-DnsName for LDAP SRV records
- ipconfig /all
- dcdiag /v

## Results
Core Active Directory and DNS functionality is operational.

SYSVOL and NETLOGON validation passed, domain-controller discovery is working, and DNS SRV records correctly resolve DC01.

## Open Findings
dcdiag reported DFS Replication and SystemLog warnings generated during/after promotion.

These were retained for later troubleshooting instead of being removed from the evidence.

## Evidence
See:

`../../evidence/active-directory/`