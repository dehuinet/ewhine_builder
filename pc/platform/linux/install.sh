#!/bin/bash
if [ $1 == "install" ]; then
  # install
  mkdir -p /opt/minxing
  if [ -d "exe_builds/Minxing/linux32"]; then
    cp -r ./exe_builds/Minxing/linux32/* /opt/minxing/
    cp ./exe_builds/Minxing/linux32/minxing.desktop /usr/share/applications/
  fi

  if [ -d "exe_builds/Minxing/linux64"]; then
    cp -r ./exe_builds/Minxing/linux64/* /opt/minxing/
    cp ./exe_builds/Minxing/linux64/minxing.desktop /usr/share/applications/
  fi

  echo "installed to /opt/minxing ."

else if [ $1 == "uninstall" ];then
  # uninstall
  rm -rf /opt/minxing /usr/share/applications/minxing.desktop
  echo "deleted."
else
  # usage
  echo "install.sh <install|uninstall>"
fi
