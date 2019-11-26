How to build an official release of the app
===========================================

Prerequesites
-------------

Make sure you are on the most recent version of the OS with the most recent version of XCode installed.

For code signing, you will need a valid Apple Developer ID Certificate. The certificate common name will need to be
updated in a few places:
* dmg-maker-bash/create-and-sign-dmg.sh
* the Xcode project itself, under Targets (select target)->General->Identity->Team

Get the code
------------

This is important: always build from a new clone. This way you are sure that what you build is really what is coming from github and that there is no local changes.

Don't do the build from XCode, use the command line. This is more resilient to changes in XCode. Open a Terminal, create a new directory somewhere and clone the code from github:

    git clone git@github.com:velocitek/speedtrack.git

Then move in the app directory

Install dependencies
------------------------

    brew install carthage
    cd VelocitekControlCenter
    carthage update --platform macOS

Bump versions
-------------

Bump the marketing version number. It is currently 1.1, you can change it to whatever is desired:

    /usr/bin/agvtool new-marketing-version 42.51

Bump the version number (if this doesn't work the developer tools are not properly installed, please install them now)

    /usr/bin/agvtool bump
    git diff

Verify the version bumped properly

    git commit -a -m "Bumped version to XX"
    git push

Check on github that your version number made it there.

Build the Mac OSX application
-----------------------------

Just run the following command:

    xcodebuild -project "Velocitek Control Center.xcodeproj" -target "Velocitek Control Center" -configuration Release

The XCode project is configured to codesign the release app. You may need to update the project to use whatever certificate/team information you have available.

Creating the Installer DMG
--------------------------

To create the installer DMG, cd to the "dmg-maker-bash" directory and run:

    ./create-and-sign-dmg

This will generate the DMG with the icon layout and artwork, and will sign the DMG using codesign. The final DMG is placed in the "distribution" directory.

Continuous Integration
----------------------

This project is built automatically by Github Actions. 

Unfortunately, generating the DMG file with the icon in the right place seems to
be a really hard problem to solve on continuous integration so we are still
doing this manually for now.

See https://github.com/andreyvit/create-dmg/issues/72
