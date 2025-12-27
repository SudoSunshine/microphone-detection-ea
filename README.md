# Jamf Pro - Built-in Microphone Detection

[![ShellCheck](https://github.com/SudoSunshine/jamf-microphone-detection/actions/workflows/shellcheck.yml/badge.svg)](https://github.com/SudoSunshine/jamf-microphone-detection/actions/workflows/shellcheck.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![macOS](https://img.shields.io/badge/macOS-11%2B-blue)](https://www.apple.com/macos/)

A production-ready Jamf Pro Extension Attribute that detects whether a Mac's built-in microphone is physically disabled (hardware kill switch) or functioning normally.

## 🎯 Purpose

Organizations with high-security requirements often deploy Macs with physical microphone kill switches. This Extension Attribute provides reliable detection of:
- ✅ Physically disabled built-in microphones
- ✅ Software-restricted microphones (MDM/TCC)
- ✅ External microphone usage
- ✅ Hardware vs software issues

## ✨ Features

- **Multi-layer Detection**: Hardware enumeration + software validation
- **High Accuracy**: Weighted check system (critical + supportive checks)
- **Zero Dependencies**: No external tools required (afrecord, timeout, etc.)
- **Universal Compatibility**: Intel & Apple Silicon | macOS 11-15+
- **Production Ready**: Shellcheck compliant, fully tested, documented

## 📊 Detection Results

| Result | Description | Use Case |
|--------|-------------|----------|
| `Available and Working` | Microphone present and functional | Normal operation |
| `Unavailable or Disabled` | Hardware kill switch engaged | **Target detection** |
| `Available but Restricted` | Software block (MDM/TCC/driver) | Review restrictions |
| `External Microphone Detected` | Built-in disabled, external active | Policy review |
| `Not Applicable` | Model has no built-in mic (Mac Pro) | Expected |

## 🚀 Quick Start

### Installation in Jamf Pro

1. Navigate to: **Settings → Computer Management → Extension Attributes**
2. Click **+ New**
3. Configure:
```
   Display Name: Built-in Microphone Status
   Data Type: String
   Input Type: Script
```
4. Paste the contents of `microphone_check.sh`
5. Save

### Creating a Smart Group

Create a Smart Group to track devices with disabled microphones:
```
Name: Macs with Disabled Built-in Microphones
Criteria: Built-in Microphone Status | is | Unavailable or Disabled
```

## 📖 Documentation

- [Deployment Guide](docs/DEPLOYMENT.md) - Detailed Jamf Pro setup
- [Troubleshooting](docs/TROUBLESHOOTING.md) - Common issues and solutions
- [Testing Guide](docs/TESTING.md) - Validation procedures

## 🧪 Testing

Run the script locally to verify functionality:
```bash
# Clone the repository
git clone https://github.com/SudoSunshine/jamf-microphone-detection.git
cd jamf-microphone-detection

# Make executable
chmod +x microphone_check.sh

# Run test
sudo ./microphone_check.sh
```

**Expected output:**
```xml
<result>Available and Working</result>
```

Run the comprehensive test suite:
```bash
chmod +x examples/test_suite.sh
sudo ./examples/test_suite.sh
```

## 🔍 How It Works

### Layer 1: Hardware Detection
- Checks `system_profiler` for built-in input devices
- Validates via `ioreg` for AppleHDA/Audio devices
- Verifies audio codec input capabilities
- Examines device tree for hardware declarations

### Layer 2: Software Validation
**Critical Checks (both must pass):**
- CoreAudio daemon running
- Input device accessible via system APIs

**Supportive Checks (2+ must pass):**
- Audio kernel extensions loaded
- No MDM microphone restrictions
- No TCC permission denials
- Low CoreAudio error rate

### Decision Matrix

| Hardware | Software | Result |
|----------|----------|--------|
| ✅ Detected | ✅ Working | Available and Working |
| ✅ Detected | ❌ Not Working | Available but Restricted |
| ❌ Not Detected | ✅ Working | External Microphone Detected |
| ❌ Not Detected | ❌ Not Working | **Unavailable or Disabled** |

## 🔧 Requirements

- **macOS**: 11.0+ (Big Sur through Sequoia)
- **Jamf Pro**: Any version supporting Extension Attributes
- **Permissions**: Script runs with elevated privileges via Jamf agent

## 📝 Version History

See [CHANGELOG.md](CHANGELOG.md) for detailed version history.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👤 Author

**Ellie Romero**
- GitHub: [@SudoSunshine](https://github.com/SudoSunshine)

## 🙏 Acknowledgments

- Developed through iterative testing and refinement
- Special thanks to the Jamf community
- Built with security-focused organizations in mind

## ⭐ Support

If you find this Extension Attribute helpful, please consider:
- ⭐ Starring this repository
- 🐛 Reporting issues
- 💡 Suggesting improvements
- 📖 Improving documentation

## 📬 Contact

- GitHub Issues: [Report a bug or request a feature](https://github.com/SudoSunshine/jamf-microphone-detection/issues)

---

**Note**: This tool detects hardware status only. For microphone access permissions and privacy controls, refer to macOS System Settings and your MDM configuration.
