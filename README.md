# Built-in Microphone Detection for Jamf Pro

![Shell](https://img.shields.io/badge/shell-bash-yellow.svg)
![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Version](https://img.shields.io/badge/version-6.3.0-green.svg)
![macOS](https://img.shields.io/badge/macOS-11.0+-blue.svg)
![Jamf Pro](https://img.shields.io/badge/Jamf%20Pro-10.0+-orange.svg)

An extension attribute that detects physically disabled built-in microphones on macOS. Returns one of five states: working, disabled, restricted, external mic detected, or not applicable.

## What It Returns
```
Available and Working          → Microphone present and functional
Unavailable or Disabled        → Hardware kill switch or physically removed
Available but Restricted       → Present but blocked by MDM/TCC/driver issue
External Microphone Detected   → Built-in disabled, external mic active
Not Applicable                 → No built-in mic (Mac Pro, some Mac minis)
```

## Install

**Jamf Pro:**
1. Settings → Computer Management → Extension Attributes → New
2. Display Name: `Built-in Microphone Status` | Data Type: `String` | Input Type: `Script`
3. Paste `microphone_check.sh` contents → Save

Results appear after next inventory update.

**Smart Group:**
```
Criteria: Built-in Microphone Status | is | Unavailable or Disabled
```

## How It Works

**Hardware checks:**
- `system_profiler SPAudioDataType` for built-in input devices
- `ioreg` for AppleHDA/Audio hardware
- Audio codec capabilities
- Device tree

**Software checks:**
- CoreAudio daemon running (critical)
- Input device accessible (critical)
- Audio drivers loaded (supportive)
- No MDM restrictions (supportive)
- No TCC denials (supportive)
- Low error rate (supportive)

**Logic:**
Both critical checks + 2 of 4 supportive checks must pass for "Available and Working". Hardware and software validation must agree for high confidence.

## Test Locally
```bash
curl -O https://raw.githubusercontent.com/SudoSunshine/jamf-microphone-detection/main/microphone_check.sh
chmod +x microphone_check.sh
sudo ./microphone_check.sh
```

Expected: `<result>Available and Working</result>`

## Requirements

- macOS 11+ (Intel or Apple Silicon)
- Jamf Pro with Extension Attribute support
- No external dependencies

## Files
```
microphone_check.sh              Main script
docs/DEPLOYMENT.md               Deployment details
docs/TROUBLESHOOTING.md          Common issues
docs/TESTING.md                  Test scenarios
examples/test_suite.sh           Validation tests
examples/smart_group_criteria.xml Smart Group templates
```

## Technical Details

**Why both hardware and software validation?**

Single-source checks produce false positives. A crashed CoreAudio daemon causes `system_profiler` to report no microphone despite hardware being present. Multi-layer validation distinguishes hardware vs software issues.

**Tested on:**
- macOS 11-15 (Big Sur → Sequoia)
- Intel and Apple Silicon
- Hardware disabled, MDM restrictions, TCC denials, daemon crashes

**Performance:**
Executes in 2-5 seconds, read-only operations, no network calls.

## Links

- [Deployment Guide](docs/DEPLOYMENT.md)
- [Troubleshooting](docs/TROUBLESHOOTING.md)
- [Changelog](CHANGELOG.md)

## License

MIT - See [LICENSE](LICENSE)

**Author:** Ellie Romero ([@SudoSunshine](https://github.com/SudoSunshine))
