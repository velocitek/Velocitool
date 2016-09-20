This directory contains the files necessary to package the gpsar.jar (GPS Action
Replay app) into a runnable OSX app.

It uses the InfiniteKind app bundler( appbundler-1.0ea.jar). https://bitbucket.org/infinitekind/appbundler

The app is made by running the build.xml Ant script.

Apach Ant must be installed to build the app. http://ant.apache.org/

To build the app with the JRE bundled, run:
    ant bundleWithJre

To build the app without the JRE bundled, run:
    ant bundleWithoutJre

The location of the bundled JRE/JDK is set by this line (in build.xml):

    <runtime dir="/Library/Java/JavaVirtualMachines/jdk1.7.0_79.jdk/Contents/Home" />

It could be set to the current JAVA_HOME of the machine by replacing that line with this:

    <runtime dir="${env.JAVA_HOME}" />

To sign the app, there is a problem with codesigner that requires a modification
to the bundled JRE (a symlink to libjli.dylib must be converted to the actual file).

See: https://bitbucket.org/infinitekind/appbundler/issues/1/appbundle-built-on-mac-osx-1095-cannot-be

Also, it turned out that codesiging a jar with a bundled JRE was non-trivial and
required signing the bundled jars, deep signing the embedded JDK, and then deep
signing the app itself.

See:

http://stackoverflow.com/questions/26938414/code-sign-java-app-for-os-x-gatekeeper
http://docs.oracle.com/javase/7/docs/technotes/guides/jweb/packagingAppsForMac.html

A universal application stub was used to help ensure that the distribution would work on any Java JRE/JDK. However, since Mac OSX > 10.7.5 doesn't come with Java installed, I've bundled the 1.7 JRE with the app. This should make the app run on any machine.

The GPS Action Replay app is very old and unsupported. It appears to have been originally built for Java 1.4, and was last updated in 2007, around the time Java 1.6 was released.

The comm.jar library is added to the app classpath when it is bundled. This appeared to improve a couple stability issues.

See:
* [Packaging a Java App for Distribution on a Mac](http://docs.oracle.com/javase/7/docs/technotes/guides/jweb/packagingAppsForMac.html)
* [InfiniteKind appbundler](https://bitbucket.org/infinitekind/appbundler)
* [Universal Java Application Stub](https://github.com/tofi86/universalJavaApplicationStub)
