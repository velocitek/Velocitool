#!/bin/bash

if [ "$#" -ne 2 ]; then
  echo "$0: <source .app> <destination dmg>"
  exit -1
fi

if [ ! -d "$1" ]; then
  echo "Source $1 does not exist."
  exit -1
fi

SOURCE_APP=$1
TARGET_DMG=$2
WD=`dirname $0`

SOURCE_FOLDER=source_folder
DEVID="Developer ID Application: Velocitek, Inc. (TYA5L6SWSX)"
STOREID="Apple Distribution: Velocitek, Inc. (TYA5L6SWSX)"

if [ -f $SOURCE_FOLDER ];
then
  echo "Removing previous $SOURCE_FOLDER"
  rm -rf $SOURCE_FOLDER
fi

mkdir $SOURCE_FOLDER

if [ -f $TARGET_DMG ];
then
  echo "Removing previous $TARGET_DMG"
  rm $TARGET_DMG
fi

echo "Copying release build from $SOURCE_APP"
cp -R "$SOURCE_APP" source_folder/

echo "Creating DMG"
$WD/create-dmg \
--volname "Velocitek Control Center Installer" \
--volicon "../VelocitekControlCenter/AppIcon.icns" \
--background ./velocitek-installer-background3.png \
--icon-size 90 \
--icon "Velocitek Control Center.app" 130 200 \
--app-drop-link 440 200 \
--window-size 576 460 \
"$TARGET_DMG" \
source_folder/

echo "Removing temp files"
rm -rf source_folder

echo "Signing DMG"
codesign -v -s "$DEVID" $TARGET_DMG

echo "Verifying DMG verbose"
codesign --display --verbose=4 --verify $TARGET_DMG

echo "Verifying DMG with checksignature"
$WD/check-signature $TARGET_DMG

exit 0