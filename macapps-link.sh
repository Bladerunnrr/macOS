#/bin/bash
clear && rm -rf ~/macapps && mkdir ~/macapps > /dev/null && cd ~/macapps

###############################
#    Print script header      #
###############################
echo $"

 ███╗   ███╗ █████╗  ██████╗ █████╗ ██████╗ ██████╗ ███████╗
 ████╗ ████║██╔══██╗██╔════╝██╔══██╗██╔══██╗██╔══██╗██╔════╝
 ██╔████╔██║███████║██║     ███████║██████╔╝██████╔╝███████╗
 ██║╚██╔╝██║██╔══██║██║     ██╔══██║██╔═══╝ ██╔═══╝ ╚════██║
 ██║ ╚═╝ ██║██║  ██║╚██████╗██║  ██║██║     ██║     ███████║╔═════════╗
 ╚═╝     ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚═╝     ╚═╝     ╚══════╝╚═ .link ═╝\n"
 

###############################
#    Define worker functions  #
###############################
versionChecker() {
	local v1=$1; local v2=$2;
	while [ `echo $v1 | egrep -c [^0123456789.]` -gt 0 ]; do
		char=`echo $v1 | sed 's/.*\([^0123456789.]\).*/\1/'`; char_dec=`echo -n "$char" | od -b | head -1 | awk {'print $2'}`; v1=`echo $v1 | sed "s/$char/.$char_dec/g"`; done
	while [ `echo $v2 | egrep -c [^0123456789.]` -gt 0 ]; do
		char=`echo $v2 | sed 's/.*\([^0123456789.]\).*/\1/'`; char_dec=`echo -n "$char" | od -b | head -1 | awk {'print $2'}`; v2=`echo $v2 | sed "s/$char/.$char_dec/g"`; done
	v1=`echo $v1 | sed 's/\.\./.0/g'`; v2=`echo $v2 | sed 's/\.\./.0/g'`;
	checkVersion "$v1" "$v2"
}

checkVersion() {
	[ "$1" == "$2" ] && return 1
	v1f=`echo $1 | cut -d "." -f -1`;v1b=`echo $1 | cut -d "." -f 2-`;v2f=`echo $2 | cut -d "." -f -1`;v2b=`echo $2 | cut -d "." -f 2-`;
	if [[ "$v1f" != "$1" ]] || [[ "$v2f" != "$2" ]]; then [[ "$v1f" -gt "$v2f" ]] && return 1; [[ "$v1f" -lt "$v2f" ]] && return 0;
		[[ "$v1f" == "$1" ]] || [[ -z "$v1b" ]] && v1b=0; [[ "$v2f" == "$2" ]] || [[ -z "$v2b" ]] && v2b=0; checkVersion "$v1b" "$v2b"; return $?
	else [ "$1" -gt "$2" ] && return 1 || return 0; fi
}

appStatus() {
  if [ ! -d "/Applications/$1" ]; then echo "uninstalled"; else
    if [[ $5 == "build" ]]; then BUNDLE="CFBundleVersion"; else BUNDLE="CFBundleShortVersionString"; fi
    INSTALLED=`/usr/libexec/plistbuddy -c Print:$BUNDLE: "/Applications/$1/Contents/Info.plist"`
      if [ $4 == "dmg" ]; then COMPARETO=`/usr/libexec/plistbuddy -c Print:$BUNDLE: "/Volumes/$2/$1/Contents/Info.plist"`;
      elif [[ $4 == "zip" || $4 == "tar" ]]; then COMPARETO=`/usr/libexec/plistbuddy -c Print:$BUNDLE: "$3$1/Contents/Info.plist"`; fi
    checkVersion "$INSTALLED" "$COMPARETO"; UPDATED=$?;
    if [[ $UPDATED == 1 ]]; then echo "updated"; else echo "outdated"; fi; fi
}
installApp() {
  echo $'\360\237\214\200  - ['$2'] Downloading app...'
  if [ $1 == "dmg" ]; then curl -s -L -o "$2.dmg" $4; yes | hdiutil mount -nobrowse "$2.dmg" -mountpoint "/Volumes/$2" > /dev/null;
    if [[ $(appStatus "$3" "$2" "" "dmg" "$7") == "updated" ]]; then echo $'\342\235\214  - ['$2'] Skipped because it was already up to date!\n';
    elif [[ $(appStatus "$3" "$2" "" "dmg" "$7") == "outdated" && $6 != "noupdate" ]]; then ditto "/Volumes/$2/$3" "/Applications/$3"; echo $'\360\237\214\216  - ['$2'] Successfully updated!\n'
    elif [[ $(appStatus "$3" "$2" "" "dmg" "$7") == "outdated" && $6 == "noupdate" ]]; then echo $'\342\235\214  - ['$2'] This app cant be updated!\n'
    elif [[ $(appStatus "$3" "$2" "" "dmg" "$7") == "uninstalled" ]]; then cp -R "/Volumes/$2/$3" /Applications; echo $'\360\237\221\215  - ['$2'] Succesfully installed!\n'; fi
    hdiutil unmount "/Volumes/$2" > /dev/null && rm "$2.dmg"
  elif [ $1 == "zip" ]; then curl -s -L -o "$2.zip" $4; unzip -qq "$2.zip";
    if [[ $(appStatus "$3" "" "$5" "zip" "$7") == "updated" ]]; then echo $'\342\235\214  - ['$2'] Skipped because it was already up to date!\n';
    elif [[ $(appStatus "$3" "" "$5" "zip" "$7") == "outdated" && $6 != "noupdate" ]]; then ditto "$5$3" "/Applications/$3"; echo $'\360\237\214\216  - ['$2'] Successfully updated!\n'
    elif [[ $(appStatus "$3" "" "$5" "zip" "$7") == "outdated" && $6 == "noupdate" ]]; then echo $'\342\235\214  - ['$2'] This app cant be updated!\n'
    elif [[ $(appStatus "$3" "" "$5" "zip" "$7") == "uninstalled" ]]; then mv "$5$3" /Applications; echo $'\360\237\221\215  - ['$2'] Succesfully installed!\n'; fi;
    rm -rf "$2.zip" && rm -rf "$5" && rm -rf "$3"
  elif [ $1 == "tar" ]; then curl -s -L -o "$2.tar.bz2" $4; tar -zxf "$2.tar.bz2" > /dev/null;
    if [[ $(appStatus "$3" "" "$5" "tar" "$7") == "updated" ]]; then echo $'\342\235\214  - ['$2'] Skipped because it was already up to date!\n';
    elif [[ $(appStatus "$3" "" "$5" "tar" "$7") == "outdated" && $6 != "noupdate" ]]; then ditto "$3" "/Applications/$3"; echo $'\360\237\214\216  - ['$2'] Successfully updated!\n';
    elif [[ $(appStatus "$3" "" "$5" "tar" "$7") == "outdated" && $6 == "noupdate" ]]; then echo $'\342\235\214  - ['$2'] This app cant be updated!\n'
    elif [[ $(appStatus "$3" "" "$5" "tar" "$7") == "uninstalled" ]]; then mv "$5$3" /Applications; echo $'\360\237\221\215  - ['$2'] Succesfully installed!\n'; fi
    rm -rf "$2.tar.bz2" && rm -rf "$3"; fi
}

###############################
#    Install selected apps    #
###############################
installApp "dmg" "Chrome" "Google Chrome.app" "https://dl.google.com/chrome/mac/stable/GGRO/googlechrome.dmg" "" "" ""
installApp "dmg" "HandBrake" "HandBrake.app" "https://download.handbrake.fr/releases/1.1.1/HandBrake-1.1.1.dmg" "" "" ""
installApp "dmg" "Steam" "Steam.app" "http://media.steampowered.com/client/installer/steam.dmg" "" "" "build"
installApp "dmg" "VLC" "VLC.app" "http://get.videolan.org/vlc/3.0.16/macosx/vlc-3.0.16-intel64.dmg" "" "" ""

# Examples
# installApp "zip" "Chromium" "Chromium.app" "https://download-chromium.appspot.com/dl/Mac" "chrome-mac/" "" ""
# installApp "zip" "GitHub" "GitHub Desktop.app" "https://central.github.com/deployments/desktop/desktop/latest/darwin" "" "" ""
# installApp "tar" "FileZilla" "FileZilla.app" "https://download.filezilla-project.org/client/FileZilla_latest_macosx-x86.app.tar.bz2" "" "" ""
# installApp "dmg" "Firefox" "Firefox.app" "http://download.mozilla.org/?product=firefox-latest&os=osx&lang=en-US" "" "" ""
# installApp "dmg" "SublimeText" "Sublime Text.app" "https://download.sublimetext.com/sublime_text_build_4126_mac.zip" "" "" ""
# installApp "zip" "Visual Studio Code" "Visual Studio Code.app" "http://go.microsoft.com/fwlink/?LinkID=620882" "" "" ""
# installApp "zip" "iTerm2" "iTerm.app" "https://iterm2.com/downloads/stable/latest" "" "" ""
# installApp "zip" "Cyberduck" "Cyberduck.app" "https://update.cyberduck.io/Cyberduck-4.6.zip" "" "" ""
# installApp "dmg" "KeePassX" "KeePassX.app" "http://www.keepassx.org../releases/2.0.3/KeePassX-2.0.3.dmg" "" "" ""
# installApp "dmg" "Etcher" "Etcher.app" "https://github.com/balena-io/etcher/releases/download/v1.5.45/balenaEtcher-1.5.45.dmg" "" "" ""
# installApp "dmg" "VLC" "VLC.app" "http://get.videolan.org/vlc/3.0.16/macosx/vlc-3.0.16-intel64.dmg" "" "" ""
# installApp "dmg" "GIMP" "Gimp-2.10.app" "http://download.gimp.org/mirror/pub/gimp/v2.10/osx/gimp-2.10.30-x86_64.dmg" "" "" ""
# installApp "dmg" "Steam" "Steam.app" "http://media.steampowered.com/client/installer/steam.dmg" "" "" "build"
# installApp "dmg" "Kodi" "Kodi.app" "http://mirrors.kodi.tv/releases/osx/x86_64/kodi-18.8-Leia-x86_64.dmg" "" "" ""
# installApp "zip" "Plex" "Plex Media Player.app" "https://downloads.plex.tv/plexmediaplayer/2.58.0.1076-38e019da/PlexMediaPlayer-2.58.0.1076-38e019da-macosx-x86_64.zip" "" "" ""
# installApp "dmg" "HandBrake" "HandBrake.app" "https://download.handbrake.fr/releases/1.1.1/HandBrake-1.1.1.dmg" "" "" ""
# installApp "dmg" "Skype" "Skype.app" "http://www.skype.com/go/getskype-macosx.dmg" "" "" ""
# installApp "dmg" "Slack" "Slack.app" "https://slack.com/ssb/download-osx" "" "" ""
# installApp "dmg" "WhatsApp" "WhatsApp.app" "https://web.whatsapp.com/desktop/mac/files/WhatsApp.dmg" "" "" ""
# installApp "dmg" "Discord" "Discord.app" "https://discordapp.com/api/download?platform=osx" "" "" ""

###############################
#    Print script footer      #
###############################
echo $'--------------------------------------------------------------------------------'
echo $'\360\237\222\254  - Thank you for using macapps.link!! Liked it? Recommend us to your friends!'
echo $'\360\237\222\260  - The time is gold. Have I saved you a lot? :) - https://macapps.link/donate'
echo $'--------------------------------------------------------------------------------\n'
rm -rf ~/macapps

