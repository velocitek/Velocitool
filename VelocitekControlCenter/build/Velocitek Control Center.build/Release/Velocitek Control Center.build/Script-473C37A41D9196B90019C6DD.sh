#!/bin/sh
if [ $CONFIGURATION = Release ]; then

cd ../dmg-maker-bash
./create-and-sign-dmg.sh

fi
