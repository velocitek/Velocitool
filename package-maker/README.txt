This directory contains the Packages project used to build the installer
package.

Packages must be installed: http://s.sudre.free.fr/Software/Packages/about.html

Once Packages is installed, you can use the packagesbuild command line
utility to build the package.

packagesbuild -v Velocitek\ Control\ Center.pkgproj

The package should also be signed to avoid installation warnings.

<Developer ID Installer Cert> should be the Common Name of a Developer ID Installer
cert from developer.apple.com and installed in the keychain.

productsign --sign "<Developer ID Installer Cert>" Velocitek\ Control\ Center.pkg Velocitek\ Control\ Center.pkg.signed
