!#/bin/bash
#------------------------------------------------------------------------------------------------------------
#                   LUA LANGUAGE
#       lua-lang: https://www.lua.org/
#       luarocks: https://luarocks.org/
#------------------------------------------------------------------------------------------------------------
app-get install -y liblua5.2-dev lua5.2
app-get install -y luarocks
/usr/bin/luarocks install luaposix 35.0-1
/usr/bin/luarocks install luaredis 2.1.0-0
/usr/bin/luarocks install http 0.3-0
/usr/bin/luarocks install luasocket 3.0rc1-2
/usr/bin/luarocks install moonjson 0.1.2-1
/usr/bin/luarocks install luasec 1.2.0-1
#------------------------------------------------------------------------------------------------------------
#                   FREESWITCH:
#       code: https://github.com/signalwire/freeswitch
#       wiki: https://freeswitch.org/confluence/
#------------------------------------------------------------------------------------------------------------
cd /usr/local/src
apt-get update && apt-get install -yq gnupg2 wget lsb-release
#wget -O - https://files.freeswitch.org/repo/deb/debian-release/fsstretch-archive-keyring.asc | apt-key add -
#echo "deb http://files.freeswitch.org/repo/deb/debian-release/ `lsb_release -sc` main" > /etc/apt/sources.list.d/freeswitch.list
#echo "deb-src http://files.freeswitch.org/repo/deb/debian-release/ `lsb_release -sc` main" >> /etc/apt/sources.list.d/freeswitch.list
TOKEN = 'SIGNALWISE-PAT-TOKEN'
wget --http-user=signalwire --http-password=$TOKEN -O /usr/share/keyrings/signalwire-freeswitch-repo.gpg https://freeswitch.signalwire.com/repo/deb/debian-release/signalwire-freeswitch-repo.gpg
echo "machine freeswitch.signalwire.com login libresbc password $TOKEN" > /etc/apt/auth.conf.d/freeswitch.conf
echo "deb [signed-by=/usr/share/keyrings/signalwire-freeswitch-repo.gpg] https://freeswitch.signalwire.com/repo/deb/debian-release/ `lsb_release -sc` main" > /etc/apt/sources.list.d/freeswitch.list
echo "deb-src [signed-by=/usr/share/keyrings/signalwire-freeswitch-repo.gpg] https://freeswitch.signalwire.com/repo/deb/debian-release/ `lsb_release -sc` main" >> /etc/apt/sources.list.d/freeswitch.list
apt-get update

# Install dependencies required for the build
# apt-get install -y g++ g++-8 gcc gcc-8 autoconf automake libtool wget libncurses-dev zlib1g-dev libcurl3-gnutls libcurl4-openssl-dev libgnutls-openssl27 libpcre16-3 libpcre3-dev libpcre32-3 libpcrecpp0v5 libspeex-dev libspeex1 libspeexdsp-dev libspeexdsp1 libldns-dev libldns2 libedit-dev libspeex-dev libspeex1 libspeexdsp-dev libspeexdsp1 libsqlite3-dev libssl-dev yasm libsndfile1 libsndfile1-dev libvpx5 libopus-dev libopus0 libopusfile-dev libopusfile0
apt-get build-dep freeswitch
# wget https://files.freeswitch.org/freeswitch-releases/freeswitch-1.10.5.-release.tar.gz -O freeswitch-1.10.5.-release.tar.gz
wget https://github.com/signalwire/freeswitch/archive/refs/tags/v1.10.6.tar.gz -O freeswitch-1.10.6.tar.gz
tar -xzvf freeswitch-1.10.6.tar.gz
cd freeswitch-1.10.6

# AMR CODE
#------------------------------------------------------------------------------------------------------------
apt-get install libopencore-amrwb-dev libopencore-amrwb0 libopencore-amrwb0-dbg libvo-amrwbenc-dev libvo-amrwbenc0 vo-amrwbenc-dbg
cp /usr/include/opencore-amrwb/dec_if.h  ./src/mod/codecs/mod_amrwb/
cp /usr/include/vo-amrwbenc/enc_if.h ./freeswitch/src/mod/codecs/mod_amrwb/

apt-get install libopencore-amrnb-dev libopencore-amrnb0 libopencore-amrnb0-dbg
cp /usr/include/opencore-amrnb/interf_enc.h ./freeswitch/src/mod/codecs/mod_amr/
cp /usr/include/opencore-amrnb/interf_dec.h ./freeswitch/src/mod/codecs/mod_amr/
#------------------------------------------------------------------------------------------------------------

./bootstrap.sh -j
mv modules.conf modules.conf.origin
cat >modules.conf<< EOF
applications/mod_commands
applications/mod_dptools
applications/mod_distributor
dialplans/mod_dialplan_xml
endpoints/mod_sofia
event_handlers/mod_event_socket
languages/mod_python
languages/mod_lua
loggers/mod_console
loggers/mod_logfile
applications/mod_spandsp
#event_handlers/mod_snmp
formats/mod_sndfile
xml_int/mod_xml_rpc
xml_int/mod_xml_curl
codecs/mod_opus
codecs/mod_amrwb
codecs/mod_amr
asr_tts/mod_flite
EOF

./configure -C --prefix=/usr/local --with-rundir=/var/run/freeswitch --with-logfiledir=/var/log/freeswitch/ --enable-64 --with-openssl
make
make install
mv /usr/local/etc/freeswitch /usr/local/etc/freeswitch.origin
# mkdir -p /dev/shm
chmod 750 /var/log/freeswitch
#-------------------------- FreeSWITCH configuration --------------------------
#
#  Locations:
#
#      prefix:          /usr/local
#      exec_prefix:     /usr/local
#      bindir:          ${exec_prefix}/bin
#      confdir:         /usr/local/etc/freeswitch
#      libdir:          /usr/local/lib
#      datadir:         /usr/local/share/freeswitch
#      localstatedir:   /usr/local/var/lib/freeswitch
#      includedir:      /usr/local/include/freeswitch
#
#      certsdir:        /usr/local/etc/freeswitch/tls
#      dbdir:           /usr/local/var/lib/freeswitch/db
#      grammardir:      /usr/local/share/freeswitch/grammar
#      htdocsdir:       /usr/local/share/freeswitch/htdocs
#      fontsdir:        /usr/local/share/freeswitch/fonts
#      logfiledir:      /var/log/freeswitch/
#      modulesdir:      /usr/local/lib/freeswitch/mod
#      pkgconfigdir:    /usr/local/lib/pkgconfig
#      recordingsdir:   /usr/local/var/lib/freeswitch/recordings
#      imagesdir:       /usr/local/var/lib/freeswitch/images
#      runtimedir:      /var/run/freeswitch
#      scriptdir:       /usr/local/share/freeswitch/scripts
#      soundsdir:       /usr/local/share/freeswitch/sounds
#      storagedir:      /usr/local/var/lib/freeswitch/storage
#      cachedir:        /usr/local/var/cache/freeswitch
#
#------------------------------------------------------------------------------------------------------------
#                   G729 CODEC:
#       https://github.com/xadhoom/mod_bcg729,
#       https://github.com/BelledonneCommunications/bcg729
#------------------------------------------------------------------------------------------------------------
cd /usr/local/src
git clone https://github.com/xadhoom/mod_bcg729.git
cd mod_bcg729
sed -i 's/^FS_INCLUDES=.*/FS_INCLUDES=\/usr\/local\/include\/freeswitch/' Makefile
sed -i 's/^FS_MODULES=.*/FS_MODULES=\/usr\/local\/lib\/freeswitch\/mod/' Makefile
make
make install
#------------------------------------------------------------------------------------------------------------
#                   PYTHON3
#------------------------------------------------------------------------------------------------------------
#apt-get install -y python3 python3-dev python3-pip
wget https://www.python.org/ftp/python/3.8.9/Python-3.8.9.tar.xz
tar -xf Python-3.8.9.tar.xz
cd Python-3.8.9/
./configure --enable-optimizations
make altinstall
ln -snf /usr/local/bin/python3.8 /usr/bin/python3
ln -snf /usr/local/bin/pip3.8 /usr/bin/pip3

pip3 install --user -r /opt/libresbc/run/liberator/requirements.txt
#------------------------------------------------------------------------------------------------------------
#                   NGINX
#------------------------------------------------------------------------------------------------------------
apt-get install -y nginx
mv /etc/nginx /etc/nginx.origin

#https://bugs.launchpad.net/ubuntu/+source/nginx/+bug/1581864
sudo mkdir /etc/systemd/system/nginx.service.d
printf "[Service]\nExecStartPost=/bin/sleep 0.1\n" | sudo tee /etc/systemd/system/nginx.service.d/override.conf
#------------------------------------------------------------------------------------------------------------
#                   KAMAILIO
#       code: https://github.com/kamailio/kamailio
#       wiki: https://www.kamailio.org/wiki/
#       doc: https://www.kamailio.org/w/documentation/
#------------------------------------------------------------------------------------------------------------
cd /usr/local/src
wget https://www.kamailio.org/pub/kamailio/latest-5.5.x/src/kamailio-5.5.1_src.tar.gz
tar -xvzf kamailio-5.5.1_src.tar.gz
cd kamailio-5.5.1
apt-get install git gcc g++ flex bison make autoconf libssl-dev libcurl4-openssl-dev libxml2-dev libpcre3-dev libhiredis-dev
make include_modules="jsonrpcs outbound ndb_redis regex utils tls" cfg
make all
make install
mkdir /var/run/kamailio
# chmod 775 /var/run/kamailio
mv /usr/local/etc/kamailio /usr/local/etc/kamailio.origin
### binaries and executable /usr/local/sbin/kam*
### configuration /usr/local/etc/kamailio
### modules /usr/local/lib64/kamailio/modules/
#------------------------------------------------------------------------------------------------------------
#                   CAPTAGENT:
#       https://github.com/sipcapture/captagent
#------------------------------------------------------------------------------------------------------------
cd /usr/local/src
apt-get install libexpat-dev libpcap-dev libjson-c-dev libtool automake flex bison libgcrypt-dev libuv1-dev libpcre3-dev libfl-dev
wget https://github.com/sipcapture/captagent/archive/6.3.1.tar.gz -O captagent-6.3.1.tar.gz
tar -xzvf captagent-6.3.1.tar.gz
cd captagent-6.3.1
./build.sh
./configure --enable-compression --enable-ipv6 --enable-pcre --enable-ssl --enable-tls
make
make install
mv /usr/local/captagent/etc/captagent /usr/local/captagent/etc/captagent.origin
#------------------------------------------------------------------------------------------------------------
#                   REDIS
#------------------------------------------------------------------------------------------------------------
apt-get install redis-server
systemctl enable redis-server
#------------------------------------------------------------------------------------------------------------
#                   LIBRESBC
#------------------------------------------------------------------------------------------------------------
mkdir -p /var/log/libresbc/cdr
mkdir -p /usr/libresbc/versions
ln -snf /usr/local/bin/fs_cli /usr/bin/fscli
