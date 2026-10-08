# Test-ADBaseline.ps1
# Validates the expected Active Directory baseline for the enterprise lab.

#Requires -Modules ActiveDirectory

$ExpectedDomain = "corp.bryanlab.test"
$ExpectedNetBIOS = "BRYANLAB"
$ExpectedPDC = "DC01.corp.bryanlab.test"

$script:Failures = 0

function Test-Check {
    param (
        [bool]$Condition,
        [string]$Description
    )

    if ($Condition) {
        Write-Output "[PASS] $Description"
    }
    else {
        Write-Output "[FAIL] $Description"
        $script:Failures++
    }
}

Write-Output "=== Active Directory Baseline Validation ==="
Write-Output ""

# Domain validation
Write-Output "[Domain]"

$domain = Get-ADDomain

Test-Check ($domain.DNSRoot -eq $ExpectedDomain) `
    "DNS root is $ExpectedDomain"

Test-Check ($domain.NetBIOSName -eq $ExpectedNetBIOS) `
    "NetBIOS name is $ExpectedNetBIOS"

Test-Check ($domain.PDCEmulator -eq $ExpectedPDC) `
    "PDC Emulator is $ExpectedPDC"

Test-Check ($domain.DomainMode -eq "Windows2016Domain") `
    "Domain functional level is Windows2016Domain"

Write-Output ""

# Forest validation
Write-Output "[Forest]"

$forest = Get-ADForest

Test-Check ($forest.Name -eq $ExpectedDomain) `
    "Forest name is $ExpectedDomain"

Test-Check ($forest.ForestMode -eq "Windows2016Forest") `
    "Forest functional level is Windows2016Forest"

Test-Check ($forest.GlobalCatalogs -contains $ExpectedPDC) `
    "DC01 is a Global Catalog"

Write-Output ""

# OU validation
Write-Output "[Organizational Units]"

$ExpectedOUs = @(
    "OU=BRYANLAB-Servers,DC=corp,DC=bryanlab,DC=test",
    "OU=Application-Servers,OU=BRYANLAB-Servers,DC=corp,DC=bryanlab,DC=test",
    "OU=Database-Servers,OU=BRYANLAB-Servers,DC=corp,DC=bryanlab,DC=test",
    "OU=BRYANLAB-Workstations,DC=corp,DC=bryanlab,DC=test",
    "OU=BRYANLAB-Users,DC=corp,DC=bryanlab,DC=test",
    "OU=BRYANLAB-Service-Accounts,DC=corp,DC=bryanlab,DC=test",
    "OU=BRYANLAB-Groups,DC=corp,DC=bryanlab,DC=test"
)

foreach ($ou in $ExpectedOUs) {

    $result = Get-ADOrganizationalUnit `
        -Identity $ou `
        -ErrorAction SilentlyContinue

    Test-Check ($null -ne $result) `
        "OU exists: $($ou.Split(',')[0].Replace('OU=',''))"
}

Write-Output ""

# Security group validation
Write-Output "[Security Groups]"

$ExpectedGroups = @(
    "GG-BIS-Administrators",
    "GG-BIS-Operators",
    "GG-BIS-ReadOnly",
    "GG-SQL-Administrators"
)

foreach ($groupName in $ExpectedGroups) {

    $group = Get-ADGroup `
        -Identity $groupName `
        -ErrorAction SilentlyContinue

    Test-Check (
        $null -ne $group -and
        $group.GroupScope -eq "Global" -and
        $group.GroupCategory -eq "Security"
    ) "Global Security Group exists: $groupName"
}

Write-Output ""

# DNS SRV validation
Write-Output "[DNS / Domain Controller Discovery]"

$srvRecord = Resolve-DnsName `
    -Type SRV `
    "_ldap._tcp.dc._msdcs.$ExpectedDomain" `
    -ErrorAction SilentlyContinue |
    Where-Object { $_.Type -eq "SRV" } |
    Select-Object -First 1

$validSRV =
    $null -ne $srvRecord -and
    $srvRecord.NameTarget.TrimEnd(".") -eq $ExpectedPDC -and
    $srvRecord.Port -eq 389

Test-Check $validSRV `
    "LDAP SRV record resolves to $ExpectedPDC on port 389"

Write-Output ""
Write-Output "============================================"

if ($script:Failures -eq 0) {
    Write-Output "Baseline Status: PASS"
    Write-Output "All Active Directory baseline checks passed."
    exit 0
}
else {
    Write-Output "Baseline Status: FAIL"
    Write-Output "$script:Failures validation check(s) failed."
    exit 1
}