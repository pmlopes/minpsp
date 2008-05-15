Name "PSP DevKit"

SetCompressor /SOLID lzma

# Defines
!define REGKEY "SOFTWARE\$(^Name)"
!define VERSION @MINPSPW_VERSION@
!define COMPANY jetcube.eu
!define URL http://www.jetcube.eu
!define SDKDIR C:\pspsdk-installer

# MUI defines
!define MUI_ICON "${NSISDIR}\Contrib\Graphics\Icons\box-install.ico"
!define MUI_FINISHPAGE_NOAUTOCLOSE
!define MUI_LICENSEPAGE_CHECKBOX
!define MUI_UNICON "${NSISDIR}\Contrib\Graphics\Icons\box-uninstall.ico"
!define MUI_UNFINISHPAGE_NOAUTOCLOSE

# Included files
!include AddToPath.nsh
!include Sections.nsh
!include MUI.nsh

# Variables
Var StartMenuGroup

# Installer pages
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE licenses.txt
!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

# Installer languages
!insertmacro MUI_LANGUAGE English

# Installer attributes
OutFile pspsdk-setup-${VERSION}-nodoc.exe
InstallDir C:\pspsdk
CRCCheck on
XPStyle on
ShowInstDetails hide
VIProductVersion ${VERSION}.0
VIAddVersionKey ProductName "${NAME}"
VIAddVersionKey ProductVersion "${VERSION}"
VIAddVersionKey CompanyName "${COMPANY}"
VIAddVersionKey CompanyWebsite "${URL}"
VIAddVersionKey FileVersion "${VERSION}"
VIAddVersionKey FileDescription ""
VIAddVersionKey LegalCopyright ""
InstallDirRegKey HKLM "${REGKEY}" Path
ShowUninstDetails hide

# Installer sections
Section "!PSP DevKit" SEC0000
    SetOutPath $INSTDIR
    SetOverwrite on

	# clean up any previous installation
    Push $INSTDIR\bin
    Call RemoveFromPath
	
    Push $INSTDIR\bin
    Call AddToPath
	
    File /r ${SDKDIR}\base\*
    WriteRegStr HKLM "${REGKEY}\Components" "PSP DevKit" 1	
SectionEnd

Section "SDK Samples" SEC0001
    SetOutPath $INSTDIR
    SetOverwrite on
    File /r ${SDKDIR}\samples\*
    WriteRegStr HKLM "${REGKEY}\Components" "SDK Samples" 1
SectionEnd

Section /o "Visual Studio Support" SEC0004
    SetOutPath $INSTDIR
    SetOverwrite on
    File /r ${SDKDIR}\vstudio\*
    WriteRegStr HKLM "${REGKEY}\Components" "Visual Studio Support" 1
SectionEnd

Section -post SEC0006
    WriteRegStr HKLM "${REGKEY}" Path $INSTDIR
    SetOutPath $INSTDIR

    WriteUninstaller $INSTDIR\uninstall.exe
    SetOutPath $SMPROGRAMS\$StartMenuGroup

	CreateShortCut "$SMPROGRAMS\$StartMenuGroup\Readme ${VERSION}.lnk" "$INSTDIR\readme.txt" "" "$INSTDIR\readme.txt" 0
	CreateShortCut "$SMPROGRAMS\$StartMenuGroup\PSPSDK API.lnk" "$INSTDIR\doc\pspsdk\index.html" "" "$INSTDIR\doc\pspsdk\index.html" 0
	
    CreateShortcut "$SMPROGRAMS\$StartMenuGroup\Uninstall $(^Name).lnk" $INSTDIR\uninstall.exe
    WriteRegStr HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$(^Name)" DisplayName "$(^Name) ${VERSION}"
    WriteRegStr HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$(^Name)" DisplayVersion "${VERSION}"
    WriteRegStr HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$(^Name)" Publisher "${COMPANY}"
    WriteRegStr HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$(^Name)" URLInfoAbout "${URL}"
    WriteRegStr HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$(^Name)" DisplayIcon $INSTDIR\uninstall.exe
    WriteRegStr HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$(^Name)" UninstallString $INSTDIR\uninstall.exe
    WriteRegDWORD HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$(^Name)" NoModify 1
    WriteRegDWORD HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$(^Name)" NoRepair 1
SectionEnd

# Macro for selecting uninstaller sections
!macro SELECT_UNSECTION SECTION_NAME UNSECTION_ID
    Push $R0
    ReadRegStr $R0 HKLM "${REGKEY}\Components" "${SECTION_NAME}"
    StrCmp $R0 1 0 next${UNSECTION_ID}
    !insertmacro SelectSection "${UNSECTION_ID}"
    GoTo done${UNSECTION_ID}
next${UNSECTION_ID}:
    !insertmacro UnselectSection "${UNSECTION_ID}"
done${UNSECTION_ID}:
    Pop $R0
!macroend

# Uninstaller sections
Section /o "-un.Visual Studio Support" UNSEC0004
    DeleteRegValue HKLM "${REGKEY}\Components" "Visual Studio Support"
SectionEnd

Section /o "-un.SDK Samples" UNSEC0001
    DeleteRegValue HKLM "${REGKEY}\Components" "PSP Samples"
SectionEnd

Section /o "-un.PSP DevKit" UNSEC0000
	# clean up any previous installation
    Push $INSTDIR\bin
    Call un.RemoveFromPath
	
    RmDir /r /REBOOTOK $INSTDIR
    DeleteRegValue HKLM "${REGKEY}\Components" "PSP DevKit"
SectionEnd

Section -un.post UNSEC0006
    DeleteRegKey HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$(^Name)"
	Delete /REBOOTOK "$SMPROGRAMS\$StartMenuGroup\Readme ${VERSION}.lnk"
	Delete /REBOOTOK "$SMPROGRAMS\$StartMenuGroup\PSPSDK API.lnk"
    Delete /REBOOTOK "$SMPROGRAMS\$StartMenuGroup\Uninstall $(^Name).lnk"
    Delete /REBOOTOK $INSTDIR\uninstall.exe
    DeleteRegValue HKLM "${REGKEY}" Path
	# force delete because devpaks have no uninstaller
	DeleteRegKey HKLM "${REGKEY}\devpak"
    DeleteRegKey /IfEmpty HKLM "${REGKEY}\Components"
    DeleteRegKey /IfEmpty HKLM "${REGKEY}"
    RmDir /REBOOTOK $SMPROGRAMS\$StartMenuGroup
    RmDir /REBOOTOK $INSTDIR
SectionEnd

# Installer functions
Function .onInit
    InitPluginsDir
    StrCpy $StartMenuGroup "PSP DevKit"
FunctionEnd

# Uninstaller functions
Function un.onInit
    ReadRegStr $INSTDIR HKLM "${REGKEY}" Path
    StrCpy $StartMenuGroup "PSP DevKit"
    !insertmacro SELECT_UNSECTION "PSP DevKit" ${UNSEC0000}
    !insertmacro SELECT_UNSECTION "PSP Samples" ${UNSEC0001}
	!insertmacro SELECT_UNSECTION "Visual Studio Support" ${UNSEC0004}
FunctionEnd

# Section Descriptions
!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
!insertmacro MUI_DESCRIPTION_TEXT ${SEC0000} "Main Installation Section"
!insertmacro MUI_DESCRIPTION_TEXT ${SEC0001} "Bundle of Samples shipped with the current PSP SDK"
!insertmacro MUI_DESCRIPTION_TEXT ${SEC0004} "Adds a script called 'vsmake' that can be used inside Visual Studio with the SDK"
!insertmacro MUI_FUNCTION_DESCRIPTION_END
