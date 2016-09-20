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

    xcodebuild -project "Velocitek Control Center.xcodeproj" -target "Velocitek Control Center" -configuration Release

During the build, toward the end, a popup is going to show up asking you for the keychain password in order to sign the dmg.

Once the code is build two files should be present in ~/Sites/velocitool:

* Velocitool $marketingversion($buildversion).dmg
* rss.xml

Copy those files, plus a release note (see the xml for the expected name of the files), at the right place on the servers (See the xml again, to see the expected URLs).

GPS Action Replay / App Builder
-------------------------------

The app-builder subdirectory contains an ant script (build.xml) that can be used to build an app bundle from the gpsar.jar file. The product, build/GPS-Action-Replay.app, is linked to as a resource in the XCode project. To run this script, ant must be installed on your machine.

From within the "app-builder" you can either run "ant", which will build the bundle app without the embedded JRE. Or you can run "ant bundleWithJre", which will build the app bundle with the JRE installed.

If you want to bundle the JRE, the location of the used JRE/JDK is set by this line (in build.xml):

    <runtime dir="/Library/Java/JavaVirtualMachines/jdk1.7.0_79.jdk/Contents/Home" />

It could be set to the current JAVA_HOME of the machine by replacing that line with this:

    <runtime dir="${env.JAVA_HOME}" />

The appbundler-1.0ea.jar is InfiniteKind's build of the Oracle app-bundler.

A universal application stub was used to help ensure that the distribution would work on any Java JRE/JDK. However, since Mac OSX > 10.7.5 doesn't come with Java installed, I've bundled the 1.7 JRE with the app. This should make the app run on any machine.

The GPS Action Replay app is very old and unsupported. It appears to have been originally built for Java 1.4, and was last updated in 2007, around the time Java 1.6 was released.

The comm.jar library is added to the app classpath when it is bundled. This appeared to improve a couple stability issues.

See:
* [Packaging a Java App for Distribution on a Mac](http://docs.oracle.com/javase/7/docs/technotes/guides/jweb/packagingAppsForMac.html)
* [InfiniteKind appbundler](https://bitbucket.org/infinitekind/appbundler)
* [Universal Java Application Stub](https://github.com/tofi86/universalJavaApplicationStub)
