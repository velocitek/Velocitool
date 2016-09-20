#! /bin/bash
PRIVATE_CERT_COMMON_NAME="Andrew Hughes"
PATH_TO_JDK="/Library/Java/JavaVirtualMachines/jdk1.7.0_79.jdk/Contents/Home"

echo "Using JDK: $PATH_TO_JDK"
echo "Signing with cert: $PRIVATE_CERT_COMMON_NAME"

$JAVA_HOME/bin/javapackager -deploy \
-Bidentifier=com.velocitek.gpsar \
-BappVersion=3.3.3 \
-BmainJar=gpsar.jar \
-Bruntime="$PATH_TO_JDK" \
-BsystemWide=true \
-Bmac.signing-key-user-name="$PRIVATE_CERT_COMMON_NAME" \
-native image \
-outdir .  \
-outfile gpasr.app \
-srcdir sourcedir \
-srcfiles gpsar.jar -srcfiles comm.jar \
-appclass GPSAR \
-name "GPS-Action-Replay" \
-title "GPS Action Replay"
