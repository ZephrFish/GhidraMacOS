# Ghidra macOS Application Launcher
I started using Ghidra recently and the brew install works fine but I wanted a .app to be able to launch from so this repo serves as a basline guide for creating a native macOS application launcher for Ghidra installed via Homebrew.

## Overview

Ghidra installed via Homebrew provides `ghidraRun` command-line tool but no macOS `.app` bundle. This means no Spotlight, Launchpad, or Applications folder access.

This guide creates a proper macOS application launcher with the official Ghidra icon.

## Prerequisites

- Ghidra installed via Homebrew: `brew install ghidra`
- macOS developer tools (sips, iconutil)

## Quick Installation

```bash
cd /Users/zephr/tools/GhidraMacOS
./install-launcher.sh
```

## Manual Installation

### Step 1: Create App Bundle Structure

```bash
mkdir -p /Applications/Ghidra.app/Contents/MacOS
mkdir -p /Applications/Ghidra.app/Contents/Resources
```

Structure:
```
Ghidra.app/
└── Contents/
    ├── MacOS/          # Executable files
    ├── Resources/      # Icons and assets
    └── Info.plist      # App metadata
```

### Step 2: Create Launcher Script

File: `/Applications/Ghidra.app/Contents/MacOS/Ghidra`

```bash
#!/bin/bash

# Set up path env variable
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

# Launch the app via the path that brew dumps it to
exec /opt/homebrew/bin/ghidraRun "$@"
```

Make the thing executable:
```bash
chmod +x /Applications/Ghidra.app/Contents/MacOS/Ghidra
```

### Step 3: Create Info.plist

File: `/Applications/Ghidra.app/Contents/Info.plist`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleExecutable</key>
    <string>Ghidra</string>
    <key>CFBundleIdentifier</key>
    <string>gov.nsa.ghidra</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>Ghidra</string>
    <key>CFBundleDisplayName</key>
    <string>Ghidra</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>11.4.2</string>
    <key>CFBundleVersion</key>
    <string>11.4.2</string>
    <key>LSMinimumSystemVersion</key>
    <string>10.13</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>LSApplicationCategoryType</key>
    <string>public.app-category.developer-tools</string>
    <key>CFBundleIconFile</key>
    <string>Ghidra</string>
</dict>
</plist>
```

Key fields:
- `CFBundleExecutable`: Executable name in MacOS folder
- `CFBundleIdentifier`: Unique app identifier
- `CFBundleVersion`: Ghidra version number
- `CFBundleIconFile`: Icon filename (without .icns extension)

### Step 4: Create and Install Icon

Locate source icon:
```bash
/opt/homebrew/Cellar/ghidra/11.4.2/libexec/docs/images/GHIDRA_1.png
```

Create iconset with all required sizes:

```bash
mkdir -p /tmp/ghidra-icon.iconset

# Generate required icon sizes
sips -z 16 16 /opt/homebrew/Cellar/ghidra/11.4.2/libexec/docs/images/GHIDRA_1.png \
  --out /tmp/ghidra-icon.iconset/icon_16x16.png

sips -z 32 32 /opt/homebrew/Cellar/ghidra/11.4.2/libexec/docs/images/GHIDRA_1.png \
  --out /tmp/ghidra-icon.iconset/icon_16x16@2x.png

sips -z 32 32 /opt/homebrew/Cellar/ghidra/11.4.2/libexec/docs/images/GHIDRA_1.png \
  --out /tmp/ghidra-icon.iconset/icon_32x32.png

sips -z 64 64 /opt/homebrew/Cellar/ghidra/11.4.2/libexec/docs/images/GHIDRA_1.png \
  --out /tmp/ghidra-icon.iconset/icon_32x32@2x.png

sips -z 128 128 /opt/homebrew/Cellar/ghidra/11.4.2/libexec/docs/images/GHIDRA_1.png \
  --out /tmp/ghidra-icon.iconset/icon_128x128.png

sips -z 256 256 /opt/homebrew/Cellar/ghidra/11.4.2/libexec/docs/images/GHIDRA_1.png \
  --out /tmp/ghidra-icon.iconset/icon_128x128@2x.png

sips -z 256 256 /opt/homebrew/Cellar/ghidra/11.4.2/libexec/docs/images/GHIDRA_1.png \
  --out /tmp/ghidra-icon.iconset/icon_256x256.png

sips -z 512 512 /opt/homebrew/Cellar/ghidra/11.4.2/libexec/docs/images/GHIDRA_1.png \
  --out /tmp/ghidra-icon.iconset/icon_256x256@2x.png

sips -z 512 512 /opt/homebrew/Cellar/ghidra/11.4.2/libexec/docs/images/GHIDRA_1.png \
  --out /tmp/ghidra-icon.iconset/icon_512x512.png

sips -z 1024 1024 /opt/homebrew/Cellar/ghidra/11.4.2/libexec/docs/images/GHIDRA_1.png \
  --out /tmp/ghidra-icon.iconset/icon_512x512@2x.png
```

Convert to .icns:
```bash
iconutil -c icns /tmp/ghidra-icon.iconset \
  -o /Applications/Ghidra.app/Contents/Resources/Ghidra.icns

rm -rf /tmp/ghidra-icon.iconset
```

### Step 5: Refresh macOS Icon Cache

```bash
touch /Applications/Ghidra.app
killall Finder
```

### Step 6: Verify Installation

```bash
ls -R /Applications/Ghidra.app/
```

Expected output:
```
Contents

/Applications/Ghidra.app/Contents:
Info.plist
MacOS
Resources

/Applications/Ghidra.app/Contents/MacOS:
Ghidra

/Applications/Ghidra.app/Contents/Resources:
Ghidra.icns
```

## Usage

Launch methods:

| Method | Action |
|--------|--------|
| Spotlight | Cmd+Space, type "Ghidra" |
| Finder | /Applications/, double-click Ghidra |
| Terminal | `open -a Ghidra` |
| Dock | Drag from Applications to Dock |

## First Launch Security

macOS may show security warning on first launch:

1. Open System Settings > Privacy & Security
2. Find Ghidra security message
3. Click Open Anyway
4. Confirm

Only required once.

## Troubleshooting

### Icon Not Showing

```bash
touch /Applications/Ghidra.app
killall Dock
killall Finder
```

### App Won't Launch

Check permissions:
```bash
ls -l /Applications/Ghidra.app/Contents/MacOS/Ghidra
# Should show: -rwxr-xr-x

# Fix if needed:
chmod +x /Applications/Ghidra.app/Contents/MacOS/Ghidra
```

Verify ghidraRun:
```bash
which ghidraRun
# Should output: /opt/homebrew/bin/ghidraRun

# If not found:
brew link ghidra
```

### Updating After Ghidra Upgrade

```bash
# Get current version
brew info ghidra | grep "ghidra:"

# Update version in Info.plist CFBundleVersion and CFBundleShortVersionString
```

## Uninstallation

```bash
rm -rf /Applications/Ghidra.app
```

Does not affect Homebrew Ghidra installation.

## Other links:

- [Ghidra GitHub](https://github.com/NationalSecurityAgency/ghidra)
- [Apple Bundle Programming Guide](https://developer.apple.com/library/archive/documentation/CoreFoundation/Conceptual/CFBundles/)
- [Info.plist Keys](https://developer.apple.com/library/archive/documentation/General/Reference/InfoPlistKeyReference/)
