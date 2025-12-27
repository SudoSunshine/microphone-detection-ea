# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [6.3.0] - 2024-11-20

### Added
- Multi-layer detection system (hardware + software validation)
- Weighted check system (critical vs supportive checks)
- Support for macOS 15 (Sequoia)
- External microphone detection
- Model pre-screening for devices without built-in mics
- Comprehensive documentation and testing suite
- Zero external dependencies (no afrecord, timeout required)

### Changed
- Replaced `afrecord` with system API checks for reliability
- Removed `timeout` dependency for macOS compatibility
- Improved TCC database query logic
- Enhanced error handling and edge case coverage

### Fixed
- TCC database comparison logic (string vs integer)
- Client bundle ID detection for Jamf context
- Volume=0 false positive (muted ≠ disabled)
- Shellcheck compliance (all warnings resolved)
- macOS 15 compatibility issues

## [6.2.0] - 2024-11-20

### Fixed
- Removed timeout command dependency (not available on macOS by default)
- Implemented native timeout using background processes

## [6.1.0] - 2024-11-20

### Fixed
- All shellcheck warnings resolved
- Added local variable declarations
- Improved grep usage (grep -c instead of grep|wc)

## [6.0.0] - 2024-11-19

### Added
- Initial public release
- Multi-layer validation approach
- Comprehensive testing suite
- Production-ready error handling

[6.3.0]: https://github.com/SudoSunshine/jamf-microphone-detection/releases/tag/v6.3.0
[6.2.0]: https://github.com/SudoSunshine/jamf-microphone-detection/releases/tag/v6.2.0
[6.1.0]: https://github.com/SudoSunshine/jamf-microphone-detection/releases/tag/v6.1.0
[6.0.0]: https://github.com/SudoSunshine/jamf-microphone-detection/releases/tag/v6.0.0
