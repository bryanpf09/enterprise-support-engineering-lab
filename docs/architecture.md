\# Enterprise Support Engineering Lab — Architecture



\*\*Document Version:\*\* 0.1  

\*\*Project Phase:\*\* Phase 0 — Architecture and Design  

\*\*Status:\*\* Initial Design



\## Project Purpose



This project is a hands-on enterprise infrastructure and support-engineering lab built around Keenfinity Building Integration System (BIS).



The environment is designed to reproduce a realistic enterprise deployment while refreshing and expanding skills in:



\- Windows Server administration

\- Active Directory

\- DNS

\- Group Policy

\- Microsoft SQL Server

\- SQL Server Reporting Services

\- Enterprise application deployment

\- Networking

\- Firewalls and VPN

\- Certificates and PKI

\- Monitoring

\- PowerShell and automation

\- Performance analysis

\- Packet analysis

\- Incident troubleshooting

\- Root-cause analysis



The environment will first be established as a known-good working deployment. Performance constraints and failures will later be introduced deliberately and analyzed using structured troubleshooting methods.



\## Physical Environment



\### Primary VMware Host



\- AMD Ryzen 9 processor

\- 32 GB RAM

\- Approximately 700 GB available storage

\- VMware Workstation



Initial virtual machines:



\- BIS01

\- SQL01



\### Secondary VMware Host



\- Intel Core i5-class processor

\- 8 GB RAM

\- VMware Workstation



Initial virtual machines:



\- DC01



\### Client Computer



\- Intel Core i5-class processor

\- 8 GB RAM

\- Physical Windows workstation



Initial role:



\- CLIENT01



CLIENT01 will later also be used for remote-access and VPN testing.



\## Physical Network



The enterprise lab uses a dedicated Ethernet network that is physically isolated from the normal home network and the Internet.



\### Lab Network



`10.10.10.0/24`



The dedicated network device is initially used only to provide Ethernet connectivity between the physical lab systems.



\- WAN/Internet connection: disconnected

\- DHCP: disabled

\- Internet access: none

\- Management address: `10.10.10.254`



\### Physical Host Addresses



| System | Address |

| --- | --- |

| Primary VMware host | `10.10.10.101` |

| Secondary VMware host | `10.10.10.102` |

| Lab network device | `10.10.10.254` |



The physical VMware hosts may independently use Wi-Fi for normal Internet connectivity.



The home and lab networks must not be bridged, and Windows Internet Connection Sharing must remain disabled.



\## Enterprise Lab Addressing



\*\*Network:\*\* `10.10.10.0/24`  

\*\*Subnet Mask:\*\* `255.255.255.0`



There is initially no default gateway.



| System | IP Address | Function |

| --- | --- | --- |

| FW01 | `10.10.10.1` | Future firewall, gateway and VPN |

| DC01 | `10.10.10.10` | Active Directory and DNS |

| BIS01 | `10.10.10.20` | BIS application server |

| SQL01 | `10.10.10.30` | SQL Server and SSRS |

| CLIENT01 | `10.10.10.40` | Enterprise client |

| MON01 | `10.10.10.50` | Future monitoring and automation |

| Primary VMware host | `10.10.10.101` | Virtualization host |

| Secondary VMware host | `10.10.10.102` | Virtualization host |

| Lab network device | `10.10.10.254` | Network management |



\## Active Directory Design



\*\*Active Directory DNS Domain:\*\* `corp.bryanlab.test`



\*\*NetBIOS Domain:\*\* `BRYANLAB`



\### DC01



Operating system:



`Windows Server 2019`



Initial roles:



\- Active Directory Domain Services

\- DNS

\- Group Policy infrastructure

\- Domain authentication



Domain-joined systems will eventually use:



`10.10.10.10`



as their preferred DNS server.



\## BIS01



Operating system:



`Windows Server 2019`



Initial role:



\- Keenfinity Building Integration System application/login server



BIS01 will use a remote Microsoft SQL Server rather than a locally installed production database.



Planned baseline resources:



\- 4 vCPU

\- 16 GB RAM

\- Approximately 120 GB virtual storage



\## SQL01



Operating system:



`Windows Server 2019`



Initial roles:



\- Microsoft SQL Server 2019

\- SQL Server Reporting Services

\- BIS databases

\- Reporting databases



Planned initial resources:



\- 4 vCPU

\- Approximately 8 GB RAM

\- Approximately 180–200 GB virtual storage



Resource allocation may change following documentation review and testing.



\## CLIENT01



Initial roles:



\- Windows domain member

\- BIS client

\- Enterprise test workstation

\- Future VPN endpoint

\- Future packet-analysis workstation



\## Future Infrastructure



\### FW01



Planned functions:



\- Routing

\- Firewall

\- Controlled Internet access

\- Network segmentation

\- VPN termination



\### MON01



Planned functions:



\- Infrastructure monitoring

\- Health checks

\- Automation

\- Future Linux administration exercises



\## Software Baseline



Currently planned:



\- Windows Server 2019

\- Microsoft SQL Server 2019

\- SQL Server Reporting Services

\- Keenfinity Building Integration System



Available BIS versions being considered:



\- BIS 4.9.1

\- BIS 5.0

\- BIS 6.0



The final BIS version and configuration will be based on the applicable Keenfinity installation manuals, release letters, data sheets and compatibility information.



\## Initial Network Isolation



During the initial deployment:



\- DC01 → Internet: blocked

\- BIS01 → Internet: blocked

\- SQL01 → Internet: blocked

\- CLIENT01 → Internet: blocked



No lab system will initially have a default gateway.



Required installation media will be downloaded separately and transferred into the isolated environment.



\## Build Methodology



\### Stage 1 — Known-Good Baseline



All components will first be installed using supported configurations.



The complete environment must operate correctly before resource restrictions or intentional failures are introduced.



\### Stage 2 — Baseline Measurements



Healthy-system behavior will be measured and documented.



Possible measurements include:



\- Server startup

\- Service startup

\- BIS client login

\- Application responsiveness

\- SQL responsiveness

\- Report generation

\- CPU utilization

\- Memory utilization

\- Paging

\- Disk performance

\- Network behavior



\### Stage 3 — Controlled Resource Constraints



Resources may then be reduced intentionally.



Examples include:



\- RAM reduction

\- CPU reduction

\- Storage-performance constraints



Whenever possible, only one major variable will be changed at a time.



\### Stage 4 — Failure Injection



Potential scenarios include:



\- DNS failures

\- SQL connectivity failures

\- Blocked network ports

\- Windows service failures

\- Active Directory account problems

\- Permission problems

\- Group Policy problems

\- Certificate failures

\- SSRS failures

\- VPN problems

\- Resource exhaustion



\### Stage 5 — Troubleshooting and Root-Cause Analysis



Each incident will document:



\- Incident description

\- Symptoms

\- Impact

\- Initial hypotheses

\- Diagnostic process

\- Evidence collected

\- Root cause

\- Resolution

\- Validation

\- Preventive recommendation

\- Lessons learned



Potential diagnostic tools include:



\- Windows Event Viewer

\- PowerShell

\- Performance Monitor

\- Resource Monitor

\- SQL Server logs

\- BIS logs

\- SSRS logs

\- IIS logs

\- DNS tools

\- Windows networking utilities

\- Wireshark



\## Project Phases



1\. Architecture and Design

2\. Virtual Infrastructure

3\. Active Directory and DNS

4\. SQL Server and Reporting Services

5\. BIS Deployment

6\. Client and Identity Integration

7\. Certificates and PKI

8\. Network Segmentation and Firewall

9\. Monitoring and Automation

10\. Remote Access and VPN

11\. Supported Baseline and Performance Testing

12\. Failure Injection and Troubleshooting



\## Current Logical Architecture



```text

&#x20;                   ISOLATED ENTERPRISE LAB

&#x20;                         10.10.10.0/24



&#x20;                             DC01

&#x20;                        10.10.10.10

&#x20;                        AD DS / DNS

&#x20;                             |

&#x20;                +------------+------------+

&#x20;                |            |            |

&#x20;                |            |            |

&#x20;              BIS01        SQL01       CLIENT01

&#x20;           10.10.10.20   10.10.10.30  10.10.10.40

&#x20;                |            |

&#x20;                |       SQL Server 2019

&#x20;                |            +

&#x20;                |           SSRS

&#x20;                |            |

&#x20;                +------------+

&#x20;                   BIS <-> SQL/SSRS



&#x20;                    No Internet

&#x20;                 No Default Gateway

```



\## Documentation Principle



Architecture changes, configuration decisions, experiments, troubleshooting procedures, failures and findings will be documented throughout the project.



The objective is not merely to make the environment work, but to demonstrate a repeatable enterprise support-engineering methodology.

