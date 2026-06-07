; stockd_installer.iss — Consolidated Production Installer for StockD
[Setup]
AppName=StockD
AppVersion=1.2.0
; Use {autopf} to install to C:\Program Files\StockD
DefaultDirName={autopf}\StockD
DefaultGroupName=StockD
; This icon appears in the installer's title bar/wizard
SetupIconFile=assets\images\StockD.ico
; Name of the output installer executable
OutputBaseFilename=StockD-windows-x64-setup
OutputDir=.
Compression=lzma
SolidCompression=yes
; Ensures the installer asks for admin permissions if installing to Program Files
PrivilegesRequired=admin

[Files]
; 1. Copy the primary brand icon explicitly to the installation root
; This ensures that even if Windows loses the EXE icon cache, the link exists
Source: "assets\images\StockD.ico"; DestDir: "{app}"; Flags: ignoreversion

; 2. Core native target build tree output
; The recursesubdirs flag ensures all backend_bundle files are included
Source: "build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs; Excludes: "include\*,tests\*,external\*,*.tar.gz"

[Icons]
; 3. Explicitly link the icon from the root {app} folder to the shortcuts
; This guarantees that Windows uses your icon file rather than the executable's metadata
Name: "{group}\StockD"; Filename: "{app}\StockD.exe"; IconFilename: "{app}\StockD.ico"
Name: "{autodesktop}\StockD"; Filename: "{app}\StockD.exe"; IconFilename: "{app}\StockD.ico"

[Run]
; Launch the app automatically after installation finishes
Filename: "{app}\StockD.exe"; Description: "Launch StockD Application"; Flags: nowait postinstall skipifsilent