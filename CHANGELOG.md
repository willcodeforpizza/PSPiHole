# Changelog

## 0.1.3
- Added allow/deny exact/regex domain management cmdlets

## 0.1.2
- Added gallery metadata to the module manifest for release publishing

## 0.1.1
- Fixed release tasks so dry-run publishing does not require a PowerShell Gallery API key
- Publish to PowerShell Gallery before creating the GitHub release in the full release workflow
- Exclude internal release tasks from the packaged module output

## 0.1.0
- Initial module scaffold
- Context-based auth (`Set-/Get-/Clear-PiholeContext`) with lazy session and transparent 401 retry
- Local DNS record management (`Get-/Add-/Remove-PiholeDnsRecord`)
