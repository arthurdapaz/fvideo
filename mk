#!/bin/sh
rm -rf *.deb
sudo dpkg -r com.arthurdapaz.fvideo
make package
sudo dpkg -i *.deb
killall -HUP SpringBoard
make clean
