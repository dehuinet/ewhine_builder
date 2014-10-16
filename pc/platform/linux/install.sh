#!/bin/bash
case $1 in
  install)
    # install
    mkdir -p $HOME/.opt/minxing
    chmod +x ./Minxing
    sed  "s/USER/$USER/g" ./minxing.desktop > $HOME/.local/share/applications/minxing.desktop
    cp -r ./* $HOME/.opt/minxing

    echo "installed to $HOME/.opt/minxing ."
    ;;
  uninstall|remove)
    # uninstall
    rm -rf $HOME/.opt/minxing $HOME/.local/share/applications/minxing.desktop
    echo "deleted."
    ;;
  *)
    # usage
    echo "install.sh <install|remove>"
    exit 1
esac
