#!/bin/bash
set -euo pipefail

APP_NAME="StockD"
APP_VERSION="1.2.0"
APP_DIR_NAME="StockD-${APP_VERSION}"
PROJECT_ROOT="/home/gautam/Documents/StockD"

cd "$PROJECT_ROOT" || exit 1

PYTHON_TARBALL="python.tar.gz"
PYTHON_URL="https://github.com/astral-sh/python-build-standalone/releases/download/20260510/cpython-3.12.13+20260510-x86_64-unknown-linux-gnu-install_only.tar.gz"

if [ ! -f "$PYTHON_TARBALL" ]; then
    echo "Downloading base standalone Python..."
    wget -q "$PYTHON_URL" -O "$PYTHON_TARBALL"
fi

TARGETS=("universal" "nvidia")

for TARGET in "${TARGETS[@]}"; do
    echo "==================================================="
    echo "BUILDING TARGET: linux-x64-$TARGET"
    echo "==================================================="

    rm -rf pkg_deb build/linux "backend_bundle_${TARGET}"

    # 1. Backend bundle (self-contained Python + deps)
    mkdir -p "backend_bundle_${TARGET}"
    tar -xzf "$PYTHON_TARBALL" -C "backend_bundle_${TARGET}/" --strip-components=1

    "./backend_bundle_${TARGET}/bin/python3" -m ensurepip

    if [ "$TARGET" == "universal" ]; then
        "./backend_bundle_${TARGET}/bin/pip" install \
            tensorflow \
            intel-extension-for-tensorflow \
            fastapi uvicorn pandas scikit-learn yfinance numpy peewee
    else
        "./backend_bundle_${TARGET}/bin/pip" install \
            "tensorflow[and-cuda]" \
            fastapi uvicorn pandas scikit-learn yfinance numpy peewee
    fi

    cp ML/*.py ML/*.keras ML/*.pkl "backend_bundle_${TARGET}/" 2>/dev/null || true
    cp -r ML/artifacts/ "backend_bundle_${TARGET}/" 2>/dev/null || true

    # 2. Flutter build
    flutter build linux --release --build-name="$APP_VERSION" --build-number=1
    BUNDLE_DIR="build/linux/x64/release/bundle"

    mkdir -p "$BUNDLE_DIR/data/flutter_assets/backend_bundle"
    cp -r "backend_bundle_${TARGET}/"* "$BUNDLE_DIR/data/flutter_assets/backend_bundle/"

    # 3. Launcher script (uses bundled Python)
    cat > "$BUNDLE_DIR/data/flutter_assets/backend_bundle/sage_launcher.sh" << 'EOF'
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export ML_DIR="$SCRIPT_DIR"
export LD_LIBRARY_PATH="$SCRIPT_DIR/lib:$LD_LIBRARY_PATH"
export PYTHONPATH="$SCRIPT_DIR:$PYTHONPATH"
exec "$SCRIPT_DIR/bin/python3" "$SCRIPT_DIR/main.py"
EOF
    chmod +x "$BUNDLE_DIR/data/flutter_assets/backend_bundle/sage_launcher.sh"

    # 4. DEB packaging (fully self-contained under /usr/lib/StockD-<version>)
    DEB_ROOT="pkg_deb"
    INSTALL_PREFIX="/usr/lib/${APP_DIR_NAME}"

    mkdir -p \
        "$DEB_ROOT$INSTALL_PREFIX" \
        "$DEB_ROOT/usr/bin" \
        "$DEB_ROOT/DEBIAN" \
        "$DEB_ROOT/usr/share/icons/hicolor/128x128/apps" \
        "$DEB_ROOT/usr/share/applications"

    cp -r "$BUNDLE_DIR/"* "$DEB_ROOT$INSTALL_PREFIX/"
    cp assets/images/StockD.png "$DEB_ROOT/usr/share/icons/hicolor/128x128/apps/stockd.png" 2>/dev/null || true

    # postrm for clean uninstall
    cat > "$DEB_ROOT/DEBIAN/postrm" << EOF
#!/bin/bash
if [ "\$1" = "remove" ] || [ "\$1" = "purge" ]; then
    rm -rf "$INSTALL_PREFIX"
fi
EOF
    chmod 755 "$DEB_ROOT/DEBIAN/postrm"

    INSTALLED_SIZE=$(du -sk "$DEB_ROOT" | cut -f1)

    cat > "$DEB_ROOT/DEBIAN/control" << EOF
Package: stockd-$TARGET
Version: $APP_VERSION
Section: utils
Priority: optional
Architecture: amd64
Maintainer: Gautam Mahajan
Installed-Size: $INSTALLED_SIZE
Description: StockD AI Application ($TARGET edition)
EOF
    chmod 644 "$DEB_ROOT/DEBIAN/control"

    cat > "$DEB_ROOT/usr/share/applications/stockd.desktop" << EOF
[Desktop Entry]
Name=StockD
Exec=/usr/bin/stockd
Icon=stockd
Type=Application
Categories=Utility;
Terminal=false
StartupWMClass=com.example.stockd
EOF

    cat > "$DEB_ROOT/usr/bin/stockd" << EOF
#!/bin/bash
exec "$INSTALL_PREFIX/stockd" "\$@"
EOF
    chmod 755 "$DEB_ROOT/usr/bin/stockd"

    DEB_FILE="StockD-linux-x64-$TARGET-${APP_VERSION}.deb"
    dpkg-deb --root-owner-group --build "$DEB_ROOT" "$DEB_FILE"

    if [ "$(stat -c%s "$DEB_FILE")" -gt 1992294400 ]; then
        split -b 1900M "$DEB_FILE" "${DEB_FILE}.part_"
        rm "$DEB_FILE"
    fi

    # 5. RPM packaging (self-contained, deps suppressed)
    RPM_ROOT="$HOME/rpmbuild"
    RPM_STAGE="$RPM_ROOT/BUILDROOT/${APP_NAME}-${APP_VERSION}"

    rm -rf "$RPM_ROOT"
    mkdir -p \
        "$RPM_STAGE$INSTALL_PREFIX" \
        "$RPM_STAGE/usr/bin" \
        "$RPM_STAGE/usr/share/icons/hicolor/128x128/apps" \
        "$RPM_STAGE/usr/share/applications" \
        "$RPM_ROOT/SPECS"

    cp -r "$BUNDLE_DIR/"* "$RPM_STAGE$INSTALL_PREFIX/"
    cp "$DEB_ROOT/usr/bin/stockd" "$RPM_STAGE/usr/bin/stockd"
    cp "$DEB_ROOT/usr/share/icons/hicolor/128x128/apps/stockd.png" \
       "$RPM_STAGE/usr/share/icons/hicolor/128x128/apps/stockd.png"
    cp "$DEB_ROOT/usr/share/applications/stockd.desktop" \
       "$RPM_STAGE/usr/share/applications/stockd.desktop"

    cat > "$RPM_ROOT/SPECS/StockD.spec" << EOF
%global __requires_exclude .*
%global __provides_exclude .*

Name: stockd-$TARGET
Version: $APP_VERSION
Release: 1
Summary: StockD AI Application ($TARGET edition)
License: Proprietary
BuildArch: x86_64

%description
StockD AI application.

%files
$INSTALL_PREFIX
/usr/bin/stockd
/usr/share/icons/hicolor/128x128/apps/stockd.png
/usr/share/applications/stockd.desktop

%changelog
EOF

    rpmbuild -bb --nodeps \
        --define "_topdir $RPM_ROOT" \
        --buildroot "$RPM_STAGE" \
        "$RPM_ROOT/SPECS/StockD.spec"

    RPM_FILE="StockD-linux-x64-$TARGET-${APP_VERSION}.rpm"
    if mv "$RPM_ROOT/RPMS/x86_64/"*.rpm "./$RPM_FILE" 2>/dev/null; then
        :
    elif mv "$RPM_ROOT/RPMS/noarch/"*.rpm "./$RPM_FILE" 2>/dev/null; then
        :
    else
        echo "ERROR: RPM not produced for target $TARGET"
        exit 1
    fi

    if [ "$(stat -c%s "$RPM_FILE")" -gt 1992294400 ]; then
        split -b 1900M "$RPM_FILE" "${RPM_FILE}.part_"
        rm "$RPM_FILE"
    fi

    echo "Finished target: $TARGET"
done

rm -rf pkg_deb backend_bundle_universal backend_bundle_nvidia
echo "Build complete!"

