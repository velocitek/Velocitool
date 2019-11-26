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

## Build the Mac OSX application

Run:

    make clean
    make release

## For distribution to users

Get the `.dmg` file in `distribution/dmg`.

Note: CI is unable to properly prepare the DMG (see below) so you will need to rerun the DMG build script on a developer computer.

- Get the .app file from Continuous Integration Server
- Run cd dmg-maker-bash && ./create-and-sign-dmg.sh "../distribution/dmg/VelocitekControlCenter.ipa/Velocitek Control Center.app" ../distribution/dmg/VelocitekControlCenter.dmg

## For AppStore

- Get the `.ipa` file in `distribution/appstore`.
- Create a new release in Apple Developer Portal
- Upload the IPA using Apple's Transporter

## Continuous Integration

This project is built automatically by Github Actions.

Unfortunately, generating the DMG file with the icon in the right place seems to
be a really hard problem to solve on continuous integration so we are still
doing this manually for now.

See https://github.com/andreyvit/create-dmg/issues/72
