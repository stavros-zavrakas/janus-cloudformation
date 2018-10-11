#!/bin/bash

logger "Starting provisioning"

logger "Update & upgrade"
sudo apt-get update
sudo apt-get upgrade -y

logger "gtk-doc tools installation"
wget http://launchpadlibrarian.net/368696874/gtk-doc-tools_1.28-1_all.deb
sudo dpkg -i gtk-doc-tools_1.28-1_all.deb
sudo apt-get update
sudo apt-get install -f -y

logger "gtk-doc dependency installation"
sudo apt-get install libmicrohttpd-dev libjansson-dev libssl-dev libsrtp-dev libsofia-sip-ua-dev libglib2.0-dev libopus-dev libogg-dev libcurl4-openssl-dev liblua5.3-dev pkg-config gengetopt libtool automake cmake doxygen graphviz -y

logger "fix the broken dependencies"
sudo apt --fix-broken install -y

logger "fix the broken dependencies"
git clone https://gitlab.freedesktop.org/libnice/libnice
cd libnice
./autogen.sh
./configure --prefix=/usr
make && sudo make install
cd ..

logger "libsrtp dependency installation"
wget https://github.com/cisco/libsrtp/archive/v2.1.0.tar.gz
tar xfv v2.1.0.tar.gz
cd libsrtp-2.1.0
./configure --prefix=/usr --enable-openssl
make shared_library && sudo make install
cd ..

logger "libwebsockets dependency installation"
git clone https://libwebsockets.org/repo/libwebsockets
cd libwebsockets
# If you want the stable version of libwebsockets, uncomment the next line
# git checkout v2.4-stable
mkdir build
cd build
# See https://github.com/meetecho/janus-gateway/issues/732 re: LWS_MAX_SMP
cmake -DLWS_MAX_SMP=1 -DCMAKE_INSTALL_PREFIX:PATH=/usr -DCMAKE_C_FLAGS="-fpic" ..
make && sudo make install
cd ..

logger "JANUS installation"
git clone https://github.com/meetecho/janus-gateway.git
cd janus-gateway
sh autogen.sh
./configure --prefix=/opt/janus
make
sudo make install
sudo make configs
cd ..

# sudo /opt/janus/bin/janus  --stun-server=stun.l.google.com:19302 

logger "Finished provisioning"