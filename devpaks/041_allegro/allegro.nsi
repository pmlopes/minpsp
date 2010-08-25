Name "JelloPhysics DevPak"

SetCompressor /SOLID lzma

# Defines
!define UNIX_NAME allegro
!define VERSION 4.4.1.1
!define COMPANY jetdrone
!define URL http://www.jetdrone.com

# MUI defines
!define MUI_ICON "${NSISDIR}\Contrib\Graphics\Icons\pixel-install.ico"
!define MUI_FINISHPAGE_NOAUTOCLOSE
!define MUI_LICENSEPAGE_CHECKBOX

# Included files
!include Sections.nsh
!include MUI.nsh

# Installer pages
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE license.txt
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

# Installer languages
!insertmacro MUI_LANGUAGE English

# Installer attributes
OutFile ${UNIX_NAME}-${VERSION}-pspdevpak.exe
CRCCheck on
XPStyle on
ShowInstDetails hide
VIProductVersion ${VERSION}.0.0
VIAddVersionKey ProductName "${NAME}"
VIAddVersionKey ProductVersion "${VERSION}"
VIAddVersionKey CompanyName "${COMPANY}"
VIAddVersionKey CompanyWebsite "${URL}"
VIAddVersionKey FileVersion "${VERSION}"
VIAddVersionKey FileDescription ""
VIAddVersionKey LegalCopyright ""

# Installer sections
Section -Main SEC0000
    ReadRegStr $0 HKLM "SOFTWARE\PSP DevKit" Path
    # check for core dependency
    StrCmp $0 '' +1 +3
    MessageBox MB_OK|MB_ICONSTOP 'PSP DevKit missing'
    Quit
    # check for internal dependencies
    ReadRegStr $1 HKLM "SOFTWARE\PSP DevKit\devpak" zlib
    # check for core dependency
    StrCmp $1 '1.2.2' +3 +1
    MessageBox MB_OK|MB_ICONSTOP 'Required devpak ZLib (1.2.2) missing'
    Quit
    # check for internal dependencies
    ReadRegStr $1 HKLM "SOFTWARE\PSP DevKit\devpak" libpng
    # check for core dependency
    StrCmp $1 '1.2.8' +3 +1
    MessageBox MB_OK|MB_ICONSTOP 'Required devpak PNG (1.2.8) missing'
    Quit
    # install
    SetOutPath $0
    SetOverwrite on
    File /r build\target\*
    WriteRegStr HKLM "SOFTWARE\PSP DevKit\devpak" ${UNIX_NAME} ${VERSION}
SectionEnd

# Installer functions
Function .onInit
    InitPluginsDir
FunctionEnd

