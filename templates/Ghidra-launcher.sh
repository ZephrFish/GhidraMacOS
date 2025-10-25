#!/bin/bash
# Ghidra Application Launcher
# Place this file at: /Applications/Ghidra.app/Contents/MacOS/Ghidra

# Set up environment
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

# Launch Ghidra
exec /opt/homebrew/bin/ghidraRun "$@"
