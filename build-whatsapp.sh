#!/bin/bash

VERSION="$(($(wget -qO- https://github.com/cycool29/whatsapp-for-linux/releases/latest  | grep -m 1 -o "WhatsApp for Linux.*"  | sed 's/WhatsApp for Linux //g' | head -c 2) + 1))"

echo -e "\nBuilding version: $VERSION\n"

# echo "if ('serviceWorker' in navigator) {
#    caches.keys().then(function (cacheNames) {
#        cacheNames.forEach(function (cacheName) {
#            caches.delete(cacheName);
#        });
#    });
# }" >./clear-sw-cache.js

wget -qO- https://aur.archlinux.org/cgit/aur.git/plain/whatsapp-nativefier-inject.js?h=whatsapp-nativefier-arch-electron >./clear-sw-cache.js
wget -O "${HOME}/whatsapp.png" "https://raw.githubusercontent.com/cycool29/whatsapp-for-linux/4f520138c1986ca9e3d5796b720ad960c7a2aa36/whatsapp.png"

for ARCH in armv7l arm64 x64; do
     nativefier -a ${ARCH} --inject clear-sw-cache.js --browserwindow-options '{ "webPreferences": { "spellcheck": true } }' --icon ${HOME}/whatsapp.png --single-instance --tray --maximize --user-agent "Mozilla/5.0 (X11; Linux ${ARCH}) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36" -p linux --name "WhatsApp" https://web.whatsapp.com -e "$(wget -qO- https://api.github.com/repos/electron/electron/releases/latest | jq -r '.tag_name' | sed s/v//g)"
done

for FOLDER in $(ls | grep "^WhatsApp"); do

     ARCH="$(echo ${FOLDER} | sed s/.*-//g)"

     if [ "${ARCH}" == armv7l ]; then
          ARCH=armhf
     elif [ "${ARCH}" == arm64 ]; then
          ARCH=arm64
     elif [ "${ARCH}" == x64 ]; then
          ARCH=amd64
     elif [ "${ARCH}" == ia32 ]; then
          ARCH=i386
     fi

     mkdir -p "${FOLDER}-DEB"
     cd "${FOLDER}-DEB"
     mkdir -p DEBIAN usr/share/applications usr/bin opt
     cp -a ../${FOLDER} ./opt/WhatsApp
     cp ${HOME}/whatsapp.png ./opt/WhatsApp/icon.png

     echo '#!/bin/bash
/opt/WhatsApp/WhatsApp' >./usr/bin/whatsapp

     chmod +x ./usr/bin/whatsapp

     echo "Package: whatsapp
Name: WhatsApp
Architecture: ${ARCH}
Description: An unofficial WhatsApp client for Linux, built with nativefier.
Author: cycool29 <cycool29@gmail.com>
Maintainer: cycool29 <cycool29@gmail.com>
Version: ${VERSION}.0" >./DEBIAN/control

     echo "[Desktop Entry]
Name=WhatsApp
Comment=An unofficial WhatsApp client for Linux, built with nativefier.
Exec=/opt/WhatsApp/WhatsApp
Icon=/opt/WhatsApp/icon.png
Type=Application
StartupNotify=false
StartupWMClass=WhatsApp
Categories=Internet;Chat;Network
Keywords=whatsapp;
" >./usr/share/applications/whatsapp.desktop

     cd ../

     dpkg-deb -b ${FOLDER}-DEB whatsapp_${VERSION}.0_${ARCH}.deb

done
