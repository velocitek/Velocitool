RELEASE_BUILD_SOURCE_FOLDER="../VelocitekControlCenter/build/Release"
TARGET_DMG="$RELEASE_BUILD_SOURCE_FOLDER/Velocitek-Control-Center-Installer.dmg"
SOURCE_FOLDER=source_folder


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
rm -rf source_folder
