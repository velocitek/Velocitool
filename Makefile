release:
	xcodebuild -project "VelocitekControlCenter/Velocitek Control Center.xcodeproj" -target "Velocitek Control Center" -configuration Release
	cd dmg-maker-bash && ./create-and-sign-dmg.sh

clean:
	rm -fr VelocitekControlCenter/build
	rm -fr distribution
