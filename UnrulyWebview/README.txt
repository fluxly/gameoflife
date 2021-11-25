1. Clone the repository from here:
    git clone https://gitlab.com/unrulystudios/experiments.git

2. In Xcode create a new project: File->New Project and select App.

3. Keep the defaults, use Swift and name it UnrulyWebviewTest

4. Add the StreamingAssets directory from the experiments repo to top level of UnrulyWebviewTest directory. Also add the Podfile to the top level, and replace the template ViewController.swift with the file from the repo. 

Now the project directory should look like this:

UnrulyWebviewTestUITests
UnrulyWebviewTestTests
UnrulyWebviewTest.xcodeproj
UnrulyWebviewTest
	ViewController.swift (from repo)
	SceneDelegate.swift
	Info.plist
	Base.lproj
	Assets.xcassets
	AppDelegate.swift
StreamingAssets (from repo)
Podfile (from repo)

5. This uses CocoaPods to install dependencies. The name in the podfile needs to match the project, in this case "UnrulyWebviewTest".
   If you don't have CocoaPods, run this from the command line:

	sudo gem install cocoapods

6. Then run the following while in the same directory as the Podfile:

	pod install
	
7. That will have created a new workspace called "UnrulyWebviewTest.xcworkspace". You'll have to open that from now on instead of the project file. Add StreamingAssets to the top level of the UnrulyWebviewTest project in XCode

8. Add to Info.plist:

  NSBluetoothAlwaysUsageDescription "This app uses Bluetooth"

