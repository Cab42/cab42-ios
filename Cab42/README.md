#  Cab42

git clone https://github.com/Cab42/cab42-ios.git
cd firestore-codelab-extended-swift
pod install


Open Cab42.xcworkspace in Xcode and run it (Cmd+R). The app should compile correctly and immediately crash on launch, since it's missing a GoogleService-Info.plist file. We'll correct that in the next step.

Go to https://console.firebase.google.com/u/0/project/cab42-mk92fg/settings/general/ios:com.mc.cab42

Download the GoogleService-Info.plist file and drag it into your Xcode project. Note that this file name must match exactly. If you end up with a name like GoogleService-Info (2).plist because of duplicate files in your downloads folder, you'll need to rename it to the original file name.
