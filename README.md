How to build an official release of the app
===========================================

Prerequesites
-------------

Make sure you are on the most recent version of the OS with the most recent version of XCode installed.

To package the GPS Action Replay app, you will also need to install Apache Ant.

For code signing, you will need a valid Apple Developer ID Certificate. The certificate common name will need to be
updated in a few places:
* app-builder/build.xml
* dmg-maker-bash/create-and-sign-dmg.sh
* the Xcode project itself, under Targets (select target)->General->Identity->Team

Get the code
------------

This is important: always build from a new clone. This way you are sure that what you build is really what is coming from github and that there is no local changes.

Don't do the build from XCode, use the command line. This is more resilient to changes in XCode. Open a Terminal, create a new directory somewhere and clone the code from github:

    git clone git@github.com:velocitek/speedtrack.git

Then move in the app directory

    cd speedtrack/Velocitool


Install dependencies
------------------------

    brew install carthage
    cd VelocitekControlCenter
    carthage update --platform macOS


Bump versions
-------------

Change your working directory to speedtrack/Velocitool

(optional)bump the marketing version number. It is currently 1.1, you can change it to whatever is desired:

    /usr/bin/agvtool new-marketing-version 42.51

Bump the version number (if this doesn't work the developer tools are not properly installed, please install them now)

    /usr/bin/agvtool bump
    git diff

Verify the version bumped properly

    git commit -a -m "Bumped version to XX"
    git push

Check on github that your version number made it there.

Build and sign the GPS Action Replay app
----------------------------------------

This is the Gpsar "classic" referenced from this website: http://gpsactionreplay.free.fr/index.php?menu=6

It is an older Java application. We are packaging it an an executable .app with a bundled JRE
to help ensure that as many people as possible will be able to run it (regardless of their installed version of Java).

After installing Apache Ant, change your working directory to the "app-bundler" directory and run:

    ant bundleAndSignWithBundledJre

This will package the gpsar.jar (along with the comm.jar file) into an executable .app and sign the code. The final result will be output in the "app-bundler/build" directory, but you shouldn't have to
do anything with this as it's already added to the XCode project as a resource and will automatically be
included in build in the next step.

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
