#!/bin/sh

# Load certificates so that codesign can sign the app and the dmg later.
# The certificates.p12 file must be exported with a password and the key
# need to be provided by an environment variable CERT_PASSWORD

KEYCHAIN_PASSWORD=some_unsecure_password
KEY_CHAIN=macos-build.keychain

security create-keychain -p $KEYCHAIN_PASSWORD $KEY_CHAIN
# Make the keychain the default so identities are found
security default-keychain -s $KEY_CHAIN
# Unlock the keychain
security unlock-keychain -p $KEYCHAIN_PASSWORD $KEY_CHAIN
# Set keychain locking timeout to 3600 seconds
security set-keychain-settings -t 3600 -u $KEY_CHAIN

# Add certificates and secret keys to keychain and allow codesign to access them
# security import apple-development.cer -k $KEY_CHAIN -T /usr/bin/codesign
# security import apple-development.p12 -k $KEY_CHAIN -P $CERT_PASSWORD -T /usr/bin/codesign
security import velocitek.cer -k $KEY_CHAIN -T /usr/bin/codesign
security import velocitek.p12 -k $KEY_CHAIN -P $CERT_PASSWORD -T /usr/bin/codesign

echo "Add keychain to keychain-list"
security list-keychains -s $KEY_CHAIN

security set-key-partition-list -S apple-tool:,apple: -s -k $KEYCHAIN_PASSWORD  $KEY_CHAIN


echo "Install provisioning profile"
uuid=`grep UUID -A1 -a Velocitek_Control_Center_AppStore.provisionprofile |grep -io "[-a-f0-9]\{36\}"`
mkdir -p ~/Library/MobileDevice/Provisioning\ Profiles/
echo "Provisiong profile UUID: $uuid"
cp Velocitek_Control_Center_AppStore.provisionprofile ~/Library/MobileDevice/Provisioning\ Profiles/$uuid.provisionprofile