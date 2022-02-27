#!/bin/bash -e
if [[ $OSTYPE == 'linux-android'* ]]; then
pkg install git; git clone https://github.com/Tivimateuser/TataSky-Playlist-AutoUpdater; cd TataSky-Playlist-AutoUpdater; bash main.sh
elif [[ $OSTYPE == 'linux-gnu'* ]]; then
git clone https://github.com/Tivimateuser/TataSky-Playlist-AutoUpdater; cd TataSky-Playlist-AutoUpdater; bash main.sh
fi
