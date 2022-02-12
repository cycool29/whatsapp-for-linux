for ARCH in ia32 armv7l arm64 x64; do     nativefier -a ${ARCH} --inject clear-sw-cache.js --user-agent "Mozilla/5.0 (X11; CrOS ${ARCH} 13597.84.0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/95.0.4638.78 Safari/537.36" -p linux --name "WhatsApp" https://web.whatsapp.com; done

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
  
  echo '#!/bin/bash
rm -rf ~/.config/whatsapp-nativefier-*/Service Worker && /opt/WhatsApp/WhatsApp' > ./usr/bin/whatsapp
  
  echo "Package: whatsapp
Name: WhatsApp
Architecture: ${ARCH}
Description: An unofficial WhatsApp client for Linux, built with nativefier.
Author: cycool29 <cycool29@gmail.com>
Maintainer: cycool29 <cycool29@gmail.com>
Version: 1.0" > ./DEBIAN/control

  echo "[Desktop Entry]
Name=WhatsApp
Comment=An unofficial WhatsApp client for Linux, built with nativefier.
Exec=bash /usr/bin/whatsapp
Icon=/opt/WhatsApp/resources/app/icon.png
Type=Application
StartupNotify=false
StartupWMClass=WhatsApp
Categories=Internet;Chat;Network
Keywords=whatsapp;
" > ./usr/share/applications/whatsapp.desktop

  cd ../
  
  dpkg-deb -b ${FOLDER}-DEB whatsapp_${ARCH}_1.0.deb
  
done
