ARCHIVE=distribution/VelocitekControlCenter.xcarchive

$(ARCHIVE): 
	mkdir -p distribution
#	xcodebuild -project "VelocitekControlCenter/Velocitek Control Center.xcodeproj" -target "Velocitek Control Center" -configuration Release
	xcodebuild -project "VelocitekControlCenter/Velocitek Control Center.xcodeproj" -scheme 'Velocitek Control Center' -archivePath $(ARCHIVE) archive

appstore: $(ARCHIVE)
	mkdir -p distribution/appstore
	xcodebuild -project "VelocitekControlCenter/Velocitek Control Center.xcodeproj" -exportArchive -archivePath $(ARCHIVE) -exportPath "distribution/appstore/VelocitekControlCenter.ipa" -exportOptionsPlist exportAppStore.plist

appstoreupload:
	mkdir -p distribution/appstore
	xcodebuild -project "VelocitekControlCenter/Velocitek Control Center.xcodeproj" -exportArchive -archivePath $(ARCHIVE) -exportPath "distribution/appstore/VelocitekControlCenter.ipa" -exportOptionsPlist exportAppStoreUpload.plist

dmg: $(ARCHIVE)
	mkdir -p distribution/dmg
	xcodebuild -project "VelocitekControlCenter/Velocitek Control Center.xcodeproj" -exportArchive -archivePath $(ARCHIVE) -exportPath distribution/dmg/"VelocitekControlCenter.ipa" -exportOptionsPlist exportDeveloperId.plist
	cd dmg-maker-bash && ./create-and-sign-dmg.sh "../distribution/dmg/VelocitekControlCenter.ipa/Velocitek Control Center.app" ../distribution/dmg/VelocitekControlCenter.dmg

clean:
	rm -fr VelocitekControlCenter/build
	rm -fr distribution

release: clean appstore dmg