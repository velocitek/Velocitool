This directory contains the files necessary to package the gpsar.jar (GPS Action
Replay app) into a runnable OSX app.

It uses the InfiniteKind app bundler. https://bitbucket.org/infinitekind/appbundler

The app is made by running the build.xml Ant script.

Apach Ant must be installed to build the app. http://ant.apache.org/

To build the app with the JRE bundled, run: "ant bundleWithJre"

To build the app without the JRE bundled, run "ant bundleWithoutJre"
