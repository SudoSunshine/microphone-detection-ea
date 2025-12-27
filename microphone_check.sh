#!/bin/bash
################################################################################
# Author: Ellie Romero
# Version: 6.3.0
# Last Updated: 11/20/2024
#
# Purpose:
#   Detects if a Mac's built-in microphone is physically disabled
#   Multi-layer validation: Hardware detection + Software verification
#
# Return Values:
#   "Available and Working"       - Microphone present and functional
#   "Unavailable or Disabled"     - Physically disabled (target detection)
#   "Available but Restricted"    - Hardware present, software blocked
#   "External Microphone Detected"- Built-in disabled, external active
#   "Not Applicable"              - Model has no built-in microphone
#
# Compatibility:
#   - macOS 11+ (Big Sur through Sequoia)
#   - Intel and Apple Silicon Macs
#   - No external dependencies
#
# For: Jamf Pro Extension Attribute
################################################################################

check_hardware_presence() {
    if system_profiler SPAudioDataType 2>/dev/null | \
       grep -A30 "Input Device" | \
       grep -qi "Built-in"; then
        return 0
    fi
    
    if ioreg -r -c IOAudioDevice -l 2>/dev/null | \
       grep -q "AppleHDAEngineInput"; then
        return 0
    fi
    
    if ioreg -r -c IOAudioDevice -l 2>/dev/null | \
       grep -B20 -A20 "Built-in" | \
       grep -qi "input\|capture"; then
        return 0
    fi
    
    if ioreg -l 2>/dev/null | \
       grep -A100 "IOHDACodecDevice" | \
       grep -qi "input\|adc"; then
        return 0
    fi
    
    if ioreg -p IODeviceTree -l 2>/dev/null | \
       grep -i "audio" | \
       grep -qi "input\|built.*in"; then
        return 0
    fi
    
    return 1
}

check_software_functionality() {
    local CRITICAL_PASSED=0
    local SUPPORTIVE_PASSED=0
    
    if pgrep -x "coreaudiod" >/dev/null 2>&1; then
        CRITICAL_PASSED=$((CRITICAL_PASSED + 1))
    fi
    
    local DEFAULT_INPUT
    DEFAULT_INPUT=$(system_profiler SPAudioDataType 2>/dev/null | \
                    grep -A5 "Default Input Device: Yes" | \
                    grep "Built-in")
    
    if [[ -n "$DEFAULT_INPUT" ]]; then
        CRITICAL_PASSED=$((CRITICAL_PASSED + 1))
    else
        if osascript -e 'input volume of (get volume settings)' >/dev/null 2>&1; then
            CRITICAL_PASSED=$((CRITICAL_PASSED + 1))
        fi
    fi
    
    local AUDIO_KEXTS
    AUDIO_KEXTS=$(kextstat 2>/dev/null | grep -ci "AppleHDA\|AppleAudio")
    if [[ "$AUDIO_KEXTS" -gt 0 ]]; then
        SUPPORTIVE_PASSED=$((SUPPORTIVE_PASSED + 1))
    fi
    
    local MDM_RESTRICTION
    MDM_RESTRICTION=$(profiles -P 2>/dev/null | \
                      grep -i "allowmicrophone" | \
                      grep -i "false")
    if [[ -z "$MDM_RESTRICTION" ]]; then
        SUPPORTIVE_PASSED=$((SUPPORTIVE_PASSED + 1))
    fi
    
    local SYSTEM_TCC_DB="/Library/Application Support/com.apple.TCC/TCC.db"
    local TCC_OK=1
    
    if [[ -r "$SYSTEM_TCC_DB" ]]; then
        local DENIED_COUNT
        DENIED_COUNT=$(sudo sqlite3 "$SYSTEM_TCC_DB" \
            "SELECT COUNT(*) FROM access WHERE service='kTCCServiceMicrophone' AND allowed=0;" \
            2>/dev/null)
        
        if [[ "${DENIED_COUNT:-0}" -gt 0 ]]; then
            TCC_OK=0
        fi
    fi
    
    if [[ "$TCC_OK" -eq 1 ]]; then
        SUPPORTIVE_PASSED=$((SUPPORTIVE_PASSED + 1))
    fi
    
    local AUDIO_ERRORS
    AUDIO_ERRORS=$(log show \
                   --predicate 'subsystem == "com.apple.coreaudio"' \
                   --last 30m 2>/dev/null | \
                   grep -c -E "(error|fail).*(input|microphone)")
    AUDIO_ERRORS=${AUDIO_ERRORS:-0}
    
    if [[ "$AUDIO_ERRORS" -lt 10 ]]; then
        SUPPORTIVE_PASSED=$((SUPPORTIVE_PASSED + 1))
    fi
    
    if [[ "$CRITICAL_PASSED" -eq 2 ]] && [[ "$SUPPORTIVE_PASSED" -ge 2 ]]; then
        return 0
    else
        return 1
    fi
}

perform_microphone_detection() {
    local MODEL
    MODEL=$(sysctl -n hw.model 2>/dev/null)
    
    if [[ "$MODEL" =~ ^MacPro[0-9] ]] || \
       [[ "$MODEL" =~ ^Macmini[1-8], ]] || \
       [[ "$MODEL" =~ ^Mac-[A-F0-9]+$ ]]; then
        echo "Not Applicable"
        return
    fi
    
    local HARDWARE_DETECTED=0
    if check_hardware_presence; then
        HARDWARE_DETECTED=1
    fi
    
    local SOFTWARE_WORKING=0
    if check_software_functionality; then
        SOFTWARE_WORKING=1
    fi
    
    if [[ "$HARDWARE_DETECTED" -eq 1 ]] && [[ "$SOFTWARE_WORKING" -eq 1 ]]; then
        echo "Available and Working"
    elif [[ "$HARDWARE_DETECTED" -eq 1 ]] && [[ "$SOFTWARE_WORKING" -eq 0 ]]; then
        echo "Available but Restricted"
    elif [[ "$HARDWARE_DETECTED" -eq 0 ]] && [[ "$SOFTWARE_WORKING" -eq 1 ]]; then
        local FINAL_BUILTIN_CHECK
        FINAL_BUILTIN_CHECK=$(system_profiler SPAudioDataType 2>/dev/null | \
                              grep -c "Built-in")
        
        if [[ "${FINAL_BUILTIN_CHECK:-0}" -gt 0 ]]; then
            echo "Available and Working"
        else
            echo "External Microphone Detected"
        fi
    elif [[ "$HARDWARE_DETECTED" -eq 0 ]] && [[ "$SOFTWARE_WORKING" -eq 0 ]]; then
        echo "Unavailable or Disabled"
    else
        echo "Unknown Status"
    fi
}

echo "<result>$(perform_microphone_detection)</result>"
