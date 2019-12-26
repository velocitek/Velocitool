# Velocitek Control Center for Mac

## Install dependencies

    brew install carthage
    cd VelocitekControlCenter
    carthage update --platform macOS

## How to build an official release of the app

### Prerequesites

Make sure you are on the most recent version of the OS with the most recent version of XCode installed.

For code signing, you will need a valid Apple Developer ID Certificate. The certificate common name will need to be
updated in a few places:

- dmg-maker-bash/create-and-sign-dmg.sh
- the Xcode project itself, under Targets (select target)->General->Identity->Team

You need 3 certificates:

- A Developer ID certificate for distribution to users directly
- A Mac App Distribution certificate (for AppStore)
- A Mac App Installer Distribution certificate (required for AppStore too)

Three Velocitek certificates with the associated keys are saved in
'certificates.p12' in this repo. You need a key to decrypt them. Ask Thomas
Sarlandie (thomas@sarlandie.net).

## Bump versions

Bump the marketing version number. It is currently 1.1, you can change it to whatever is desired:

    /usr/bin/agvtool new-marketing-version 42.51

Bump the version number (if this doesn't work the developer tools are not properly installed, please install them now)

    /usr/bin/agvtool bump
    git diff

Verify the version bumped properly

    git commit -a -m "Bumped version to XX"
    git push

Check on github that your version number made it there.

## Continuous Integration

This project is built automatically by Github Actions.

Unfortunately, generating the DMG file with the icon in the right place seems to
be a really hard problem to solve on continuous integration so we are still
doing this manually for now.

See https://github.com/andreyvit/create-dmg/issues/72

## Distribution

As of December 2019, we were not able to fully automate the signing and release process. 

The release process must be done manually.

## For distribution to users

- Build for Archive in Xcode
- Open `Organizer` and select the build
- Click 'Distribute' and follow instructions for distribution to users directly
- Save the resulting notarized .app file in distribution/notarized

- Open DMGCanvas (paid software but the free version seems to work fine for this) and open the velocitek.dmgCanvas project from the repo
- Click Build
- DMGCanvas will build the DMG, codesign it and have Apple notarize it.
- The resulting .dmg should be fully signed and ready to distribute.

## For AppStore

- Select the archive in `Organizer`
- Click `Distribute to AppStore` and let organizer do the upload to Apple
- Create a new release and distribute via https://appstoreconnect.apple.com

