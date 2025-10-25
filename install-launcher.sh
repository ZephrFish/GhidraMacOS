#!/bin/bash
# Automated Ghidra macOS Launcher Installation 

set -e  # Exit on error

echo "Ghidra macOS Launcher Builder"
echo ""

# Check if Ghidra is installed via Homebrew
if ! command -v ghidraRun &> /dev/null; then
    echo "Error: ghidraRun not found in PATH"
    echo "Please install Ghidra via Homebrew first:"
    echo "  brew install ghidra"
    exit 1
fi

# Get Ghidra installation path
GHIDRA_BIN=$(which ghidraRun)
GHIDRA_PATH=$(brew --prefix ghidra 2>/dev/null || echo "/opt/homebrew/Cellar/ghidra/11.4.2")
GHIDRA_VERSION=$(brew info ghidra --json | grep -o '"version":"[^"]*"' | cut -d'"' -f4 || echo "11.4.2")
GHIDRA_ICON="${GHIDRA_PATH}/libexec/docs/images/GHIDRA_1.png"

echo "Found Ghidra installation:"
echo "  Binary: ${GHIDRA_BIN}"
echo "  Version: ${GHIDRA_VERSION}"
echo ""

# Create app bundle structure
echo "Creating app bundle structure..."
mkdir -p /Applications/Ghidra.app/Contents/MacOS
mkdir -p /Applications/Ghidra.app/Contents/Resources

# Create launcher script
echo "Creating launcher script..."
cat > /Applications/Ghidra.app/Contents/MacOS/Ghidra << 'EOF'
#!/bin/bash
# Ghidra Application Launcher

# Set up environment
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

# Launch Ghidra
exec /opt/homebrew/bin/ghidraRun "$@"
EOF

chmod +x /Applications/Ghidra.app/Contents/MacOS/Ghidra
echo "Done"

# Create Info.plist
echo "Creating Info.plist..."
cat > /Applications/Ghidra.app/Contents/Info.plist << EOF
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
    <string>${GHIDRA_VERSION}</string>
    <key>CFBundleVersion</key>
    <string>${GHIDRA_VERSION}</string>
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
EOF
echo "Done"

# Create icon
if [ -f "${GHIDRA_ICON}" ]; then
    echo "Creating application icon..."

    # Create temporary iconset
    ICONSET_DIR=$(mktemp -d)/ghidra-icon.iconset
    mkdir -p "${ICONSET_DIR}"

    # Generate all required icon sizes
    sips -z 16 16 "${GHIDRA_ICON}" --out "${ICONSET_DIR}/icon_16x16.png" &>/dev/null
    sips -z 32 32 "${GHIDRA_ICON}" --out "${ICONSET_DIR}/icon_16x16@2x.png" &>/dev/null
    sips -z 32 32 "${GHIDRA_ICON}" --out "${ICONSET_DIR}/icon_32x32.png" &>/dev/null
    sips -z 64 64 "${GHIDRA_ICON}" --out "${ICONSET_DIR}/icon_32x32@2x.png" &>/dev/null
    sips -z 128 128 "${GHIDRA_ICON}" --out "${ICONSET_DIR}/icon_128x128.png" &>/dev/null
    sips -z 256 256 "${GHIDRA_ICON}" --out "${ICONSET_DIR}/icon_128x128@2x.png" &>/dev/null
    sips -z 256 256 "${GHIDRA_ICON}" --out "${ICONSET_DIR}/icon_256x256.png" &>/dev/null
    sips -z 512 512 "${GHIDRA_ICON}" --out "${ICONSET_DIR}/icon_256x256@2x.png" &>/dev/null
    sips -z 512 512 "${GHIDRA_ICON}" --out "${ICONSET_DIR}/icon_512x512.png" &>/dev/null
    sips -z 1024 1024 "${GHIDRA_ICON}" --out "${ICONSET_DIR}/icon_512x512@2x.png" &>/dev/null

    # Convert to .icns
    iconutil -c icns "${ICONSET_DIR}" -o /Applications/Ghidra.app/Contents/Resources/Ghidra.icns

    # Clean up
    rm -rf "$(dirname ${ICONSET_DIR})"

    echo "Done"
else
    echo "Warning: Ghidra icon not found at ${GHIDRA_ICON}"
    echo "App will use default icon"
fi

# Refresh macOS caches
echo "Refreshing macOS icon cache..."
touch /Applications/Ghidra.app
killall Finder 2>/dev/null || true

echo ""
echo "Installation complete"
echo ""
echo "Launch Ghidra via:"
echo "  Spotlight: Cmd+Space, type 'Ghidra'"
echo "  Finder: /Applications/Ghidra.app"
echo "  Terminal: open -a Ghidra"
echo ""
echo "First launch: If macOS blocks the app, go to"
echo "System Settings > Privacy & Security > Open Anyway"
echo ""
