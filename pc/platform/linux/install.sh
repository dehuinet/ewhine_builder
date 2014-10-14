#!/bin/bash
case $1 in
  install)
    # install
    mkdir -p /opt/minxing
    chmod +x ./Minxing
    cp ./minxing.desktop /usr/share/applications/
    cp -r ./* /opt/minxing/

    echo "installed to /opt/minxing ."
    ;;
  uninstall|remove)
    # uninstall
    rm -rf /opt/minxing /usr/share/applications/minxing.desktop
    echo "deleted."
    ;;
  *)
    # usage
    echo "install.sh <install|uninstall>"
    exit 1
esac
