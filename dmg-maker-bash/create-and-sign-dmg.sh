RELEASE_BUILD_SOURCE_FOLDER="../VelocitekControlCenter/build/Release"
TARGET_DMG="../distribution/Velocitek-Control-Center-Installer.dmg"
SOURCE_FOLDER=source_folder
DEVID="Thomas Sarlandie ()"


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

echo "Copying release build from $RELEASE_BUILD_SOURCE_FOLDER"
cp -R $RELEASE_BUILD_SOURCE_FOLDER/*.app source_folder
./create-dmg \
--volname "Velocitek Control Center Installer" \
--volicon "../VelocitekControlCenter/SpeedPuck.icns" \
--background ./velocitek-installer-background3.png \
--icon-size 90 \
--icon "Velocitek Control Center.app" 130 200 \
--app-drop-link 440 200 \
--window-size 576 460 \
$TARGET_DMG \
source_folder/

echo "Removing temp files"
rm -rf source_folder

echo "Signign DMG"
codesign -v -s "Developer ID Application: $DEVID" $TARGET_DMG

echo "Verifying DMG verbose"
codesign --display --verbose=4 --verify $TARGET_DMG

echo "Verifying DMG with checksignature"
./check-signature $TARGET_DMG
