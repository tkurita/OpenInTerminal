install:
	xcodebuild -workspace 'Open in Terminal.xcworkspace' -scheme 'Open in Terminal'  -configuration Release clean install DSTROOT=${HOME}

clean:
	xcodebuild -workspace 'Open in Terminal.xcworkspace' -scheme 'Open in Terminal' -configuration Release clean DSTROOT=${HOME}
