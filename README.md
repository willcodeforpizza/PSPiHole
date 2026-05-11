<p align="center">
  <img src="Resource/PSPiHole-Banner.png" alt="PSPiHole" width="500">
</p>

# PSPiHole

## Overview

PSPiHole is a PowerShell wrapper around the [Pi-hole v6 API](https://docs.pi-hole.net/api/). Manage your Pi-Hole server using native PowerShell syntax.


Example:
```powershell
Set-PiholeContext -Server pi.hole -Credential (Get-Credential)

Get-PiholeDnsRecord
Add-PiholeDnsRecord -Hostname ha.local.mydomain.com -IPAddress 10.0.0.42
Get-PiholeDnsRecord -Hostname '*.old.lan' | Remove-PiholeDnsRecord
```

## Requirements

- PowerShell 7.0 or later
- Linux or Windows
- Pi-hole 6 or later

## Quick Start

```powershell
# Clone and import the module
git clone https://github.com/willcodeforpizza/PSPiHole.git
Import-Module ./PSPiHole/PSPiHole.psd1

# Point it at your Pi-hole (password = web admin or app password)
Set-PiholeContext -Server pi.hole -Credential (Get-Credential)

# Smoke test — auths lazily, lists local DNS records
Get-PiholeDnsRecord
```

## Authentication

Pi-Hole does not use static API keys, rather it uses a token to generate a session. With PSPiHole you can configure the server and credential once and the authentication lifecycle will be managed for you.

Auth happens lazily on the first cmdlet that needs it; the session id is cached on the context and reused until Pi-hole expires it, at which point the module re-auths transparently.

If neither `-Credential` nor `-Password` is supplied, `Set-PiholeContext` falls back to `$env:PIHOLE_PASSWORD`.

| Function | Purpose |
|---|---|
| `Set-PiholeContext` | Configure the default server, credential, and TLS behaviour.|
| `Get-PiholeContext` | Return a sanitised view of the current context.|
| `Clear-PiholeContext` | Drop the default context from the Pi-Hole server and local cache. |

## DNS Record Functions

Local DNS host records (Pi-hole's `config/dns/hosts`) as PowerShell objects: each record comes back as a `PSPiHole.DnsRecord` with `Hostname` and `IPAddress` properties.

 `Add` and `Remove` bind by property name, so `Get-PiholeDnsRecord | Remove-PiholeDnsRecord` is the natural mass-cleanup idiom. Both honour `-WhatIf` / `-Confirm`.

| Function | Purpose |
|---|---|
| `Get-PiholeDnsRecord` | List all local DNS records. Optional `-Hostname` wildcard filter applied client-side. |
| `Add-PiholeDnsRecord` | Add a host record. Idempotent on the Pi-hole side. |
| `Remove-PiholeDnsRecord` | Remove a host record.|

## Domain Functions

Allow and deny entries from Pi-hole's domain management API (`/domains`) as PowerShell objects. Use `-Type allow|deny` and `-Kind exact|regex` to target the list you want.

```powershell
Get-PiholeDomain -Type deny -Kind exact
Add-PiholeDomain -Type deny -Kind exact -Domain ads.example.com -Comment 'Nope'
Set-PiholeDomain -Type deny -Kind exact -Domain ads.example.com -Enabled:$false
Get-PiholeDomain -Type allow -Kind regex | Remove-PiholeDomain
```

| Function | Purpose |
|---|---|
| `Get-PiholeDomain` | List allow/deny domains. Optional `-Type`, `-Kind`, and `-Domain` filters are sent to the API. |
| `Add-PiholeDomain` | Add one or more exact or regex domains with optional comment, group IDs, and enabled state. |
| `Set-PiholeDomain` | Update comment, group IDs, enabled state, or move an entry between allow/deny and exact/regex lists. |
| `Remove-PiholeDomain` | Remove an exact or regex domain. |
