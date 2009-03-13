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
OutFile pspsdk-setup-${VERSION}.exe
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
    ReadRegStr $0 HKLM "SOFTWARE\PSP DevKit" Path
    StrCmp $0 '' +3 +1
    Push $0\bin
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

Section "PSP link" SEC0002
    SetOutPath $INSTDIR
    SetOverwrite on
    File /r ${SDKDIR}\psplink\*
    WriteRegStr HKLM "${REGKEY}\Components" "PSP link" 1
SectionEnd

Section "HTML Documentation" SEC0003
    SetOutPath $INSTDIR
    SetOverwrite on
    File /r ${SDKDIR}\documentation\pspdoc\*
    WriteRegStr HKLM "${REGKEY}\Components" "HTML Documentation" 1
SectionEnd

Section "Basic Devpaks" SEC0004
    SetOutPath $INSTDIR
    SetOverwrite on
    File /r ${SDKDIR}\devpaks\*
    WriteRegStr HKLM "${REGKEY}\Components" "Basic Devpaks" 1
	
	WriteRegStr HKLM "SOFTWARE\PSP DevKit\devpak" zlib 1.2.2
	WriteRegStr HKLM "SOFTWARE\PSP DevKit\devpak" bzip2 1.0.4
	WriteRegStr HKLM "SOFTWARE\PSP DevKit\devpak" freetype 2.1.10
	WriteRegStr HKLM "SOFTWARE\PSP DevKit\devpak" jpeg 6.2
	WriteRegStr HKLM "SOFTWARE\PSP DevKit\devpak" libbulletml 0.0.5
	WriteRegStr HKLM "SOFTWARE\PSP DevKit\devpak" libmad 0.15.1
	WriteRegStr HKLM "SOFTWARE\PSP DevKit\devpak" libmikmod 3.1.11
	WriteRegStr HKLM "SOFTWARE\PSP DevKit\devpak" libogg 1.1.2
	WriteRegStr HKLM "SOFTWARE\PSP DevKit\devpak" libpng 1.2.8
	WriteRegStr HKLM "SOFTWARE\PSP DevKit\devpak" libpspvram 2227
	WriteRegStr HKLM "SOFTWARE\PSP DevKit\devpak" libTremor 1.0.2
	WriteRegStr HKLM "SOFTWARE\PSP DevKit\devpak" libvorbis 1.1.2
	WriteRegStr HKLM "SOFTWARE\PSP DevKit\devpak" lua 5.1
	WriteRegStr HKLM "SOFTWARE\PSP DevKit\devpak" pspgl 2264
	WriteRegStr HKLM "SOFTWARE\PSP DevKit\devpak" pspirkeyb 0.0.4
	WriteRegStr HKLM "SOFTWARE\PSP DevKit\devpak" sqlite 3.3.17
	WriteRegStr HKLM "SOFTWARE\PSP DevKit\devpak" SDL 1.2.9
	WriteRegStr HKLM "SOFTWARE\PSP DevKit\devpak" SDL_gfx 2.0.13
	WriteRegStr HKLM "SOFTWARE\PSP DevKit\devpak" SDL_image 1.2.4
	WriteRegStr HKLM "SOFTWARE\PSP DevKit\devpak" SDL_mixer 1.2.6
	WriteRegStr HKLM "SOFTWARE\PSP DevKit\devpak" SDL_ttf 2.0.7
	WriteRegStr HKLM "SOFTWARE\PSP DevKit\devpak" smpeg-psp 0.4.5
	WriteRegStr HKLM "SOFTWARE\PSP DevKit\devpak" zziplib 0.13.38
SectionEnd

Section "Eclipse CDT 5+ Support" SEC0005
    SetOutPath $INSTDIR
    SetOverwrite on
    File /r ${SDKDIR}\eclipse\*
    WriteRegStr HKLM "${REGKEY}\Components" "Eclipse CDT 5+ Support" 1
SectionEnd

Section /o "Visual Studio Support" SEC0006
    SetOutPath $INSTDIR
    SetOverwrite on
    File /r ${SDKDIR}\vstudio\*
    WriteRegStr HKLM "${REGKEY}\Components" "Visual Studio Support" 1
SectionEnd

Section /o "Man/Info pages" SEC0007
    SetOutPath $INSTDIR
    SetOverwrite on
    File /r ${SDKDIR}\documentation\man_info\*
    WriteRegStr HKLM "${REGKEY}\Components" "Man/Info pages" 1
SectionEnd

Section -post SEC0008
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
Section /o "-un.Man/Info pages" UNSEC0007
    DeleteRegValue HKLM "${REGKEY}\Components" "Man/Info pages"
SectionEnd

Section /o "-un.Visual Studio Support" UNSEC0006
    DeleteRegValue HKLM "${REGKEY}\Components" "Visual Studio Support"
SectionEnd

Section /o "-un.Visual Studio Support" UNSEC0005
    DeleteRegValue HKLM "${REGKEY}\Components" "Eclipse CDT 5+ Support"
SectionEnd

Section /o "-un.Basic Devpaks" UNSEC0004
	# delete all devpaks since all files will be deleted after all
	DeleteRegKey HKLM "SOFTWARE\PSP DevKit\devpak"
	
    DeleteRegValue HKLM "${REGKEY}\Components" "Basic Devpaks"
SectionEnd

Section /o "-un.HTML Documentation" UNSEC0003
    DeleteRegValue HKLM "${REGKEY}\Components" "HTML Documentation"
SectionEnd

Section /o "-un.PSP link" UNSEC0002
    DeleteRegValue HKLM "${REGKEY}\Components" "PSP link"
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

Section -un.post UNSEC0008
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
    !insertmacro SELECT_UNSECTION "PSP link" ${UNSEC0002}
    !insertmacro SELECT_UNSECTION "HTML Documentation" ${UNSEC0003}
	!insertmacro SELECT_UNSECTION "Basic Devpaks" ${UNSEC0004}
	!insertmacro SELECT_UNSECTION "Eclipse CDT 5+ Support" ${UNSEC0005}
	!insertmacro SELECT_UNSECTION "Visual Studio Support" ${UNSEC0006}
	!insertmacro SELECT_UNSECTION "Man/Info pages" ${UNSEC0007}
FunctionEnd

# Section Descriptions
!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
!insertmacro MUI_DESCRIPTION_TEXT ${SEC0000} "Main Installation Section"
!insertmacro MUI_DESCRIPTION_TEXT ${SEC0001} "Bundle of Samples shipped with the current PSP SDK"
!insertmacro MUI_DESCRIPTION_TEXT ${SEC0002} "Utilities for debugging"
!insertmacro MUI_DESCRIPTION_TEXT ${SEC0003} "HTML Documentation for the SDK"
!insertmacro MUI_DESCRIPTION_TEXT ${SEC0004} "zlib bzip2 freetype jpeg libbulletml libmad libmikmod libogg libpng libpspvram libTremor libvorbis lua pspgl pspirkeyb sqlite SDL SDL_gfx SDL_image SDL_mixer SDL_ttf smpeg-psp zziplib"
!insertmacro MUI_DESCRIPTION_TEXT ${SEC0005} "Adds gcc.exe to the PATH so Eclipse CDT 5+ can auto configure itself"
!insertmacro MUI_DESCRIPTION_TEXT ${SEC0006} "Adds a script called 'vsmake' that can be used inside Visual Studio with the SDK"
!insertmacro MUI_DESCRIPTION_TEXT ${SEC0007} "Only needed if you want the Compiler Man pages, man readed included"
!insertmacro MUI_FUNCTION_DESCRIPTION_END
