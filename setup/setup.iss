; -- FibbageQE.iss --
[Setup]
AppName=FibbageQE
AppVersion=0.5
DefaultDirName={localappdata}\FibbageCQE
DisableDirPage=yes
DefaultGroupName=FibbageQE
OutputDir=.
OutputBaseFilename=FibbageCQE_Installer
Compression=lzma
SolidCompression=yes
PrivilegesRequired=lowest

[Files]
Source: "..\Source\bin\Win32\Release\FibbageQE.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "libgain.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "libzmq-win32.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "libzmq-win64.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "ogg.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "vorbis.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "vorbisenc.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "vorbisfile.dll"; DestDir: "{app}"; Flags: ignoreversion

[UninstallDelete]
Type: files; Name: "{app}\.lasts"
Type: files; Name: "{app}\FibbageQE.ini"
Type: dirifempty; Name: "{app}"

[Icons]
Name: "{userdesktop}\FibbageQE"; Filename: "{app}\FibbageQE.exe"