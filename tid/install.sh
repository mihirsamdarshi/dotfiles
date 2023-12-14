#!/bin/bash

set -euxo pipefail

# Check if running with sudo permissions
if [ "$EUID" -ne 0 ]
  then echo "Please run with sudo"
  exit 1
fi

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

cd "$SCRIPT_DIR" || exit 1

if [ ! -f "$SCRIPT_DIR/sudo-pam-tid" ]; then
    echo "sudo-pam-tid not found. Please build it first."
    exit 1
fi

chmod +x "$SCRIPT_DIR/sudo-pam-tid"

cat <<EOF > /Library/LaunchDaemons/com.user.sudo-pam-tid.plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <dict>
        <key>Label</key>
        <string>com.user.sudo-pam-tid</string>
        <key>ProgramArguments</key>
        <array>
            <string>${SCRIPT_DIR}/sudo-pam-tid</string>
        </array>
        <key>RunAtLoad</key>
        <true/>
        <key>KeepAlive</key>
        <false/>
    </dict>
</plist>
EOF