How to build an official release of the app
===========================================

Prerequesites
-------------

Make sure you are on the most recent version of the OS with the most recent version of XCode installed.

Make sure the keychain application has a secure note called "Velocitool private key" inside a "PrivateKeys" keychain. If you don't have it, ask someone to send you the encrypted keychain and install it.

Get the code
------------

This is important: always build from a new clone. This way you are sure that what you build is really what is coming from github and that there is no local changes.

Don't do the build from XCode, use the command line. This is more resilient to changes in XCode. Open a Terminal, create a new directory somewhere and clone the code from github:

    git clone git@github.com:velocitek/speedtrack.git

Then move in the app directory

    cd speedtrack/Velocitool

Install Sparkle
---------------

Go to the [Sparkle web site](http://sparkle-project.org/) and download the latest version of Sparkle. Unpack it somewhere, then copy Sparkle.framework in speedtrack/Velocitool.

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


Do the build
------------

Just run the following command:

   xcodebuild -project Velocitool.xcodeproj -target Velocitool -configuration Release

During the build, toward the end, a popup is going to show up asking you for the keychain password in order to sign the dmg.

Once the code is build two files should be present in ~/Sites/velocitool:

* Velocitool $marketingversion($buildversion).dmg
* rss.xml

Copy those files, plus a release note (see the xml for the expected name of the files), at the right place on the servers (See the xml again, to see the expected URLs).









