Name "Lib AAC DevPak"

SetCompressor /SOLID lzma

# Defines
!define UNIX_NAME libAac
!define VERSION 1088
!define COMPANY jetcube
!define URL http://www.jetcube.eu

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
OutFile ${UNIX_NAME}-rev${VERSION}-pspdevpak.exe
CRCCheck on
XPStyle on
ShowInstDetails hide
VIProductVersion 0.0.0.${VERSION}
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
    # install
    SetOutPath $0
    SetOverwrite on
    File /r target\*
    WriteRegStr HKLM "SOFTWARE\PSP DevKit\devpak" ${UNIX_NAME} ${VERSION}
SectionEnd

# Installer functions
Function .onInit
    InitPluginsDir
FunctionEnd

