Bitcasa CloudFS iOS SDK
=======================

This SDK is built on [CloudFS API].

How to use:
----------------------
1) Clone this repo.

2) Add the BitcasaSDK project file to your Xcode project. To do that, drag the BitcasaSDK.xcodeproj file into your Project Navigator.

3) Navigate to Build Phases settings of your target. Under Link Binary with Libraries, add libBitcasaSDK.a and MobileCoreServices.framework.

4) Navigate to Build Settings, and add -ObjC to Other Linker Flags.

5) Obtain a Bitcasa CloudFS App ID, secret, and API server URL. (https://www.bitcasa.com/cloudfs)

6) Add a test user account.

7) In your app, instantiate a session:
```objc
Session* session = [[Session alloc] initWithServerURL:SERVER_URL clientId:APP_ID clientSecret:APP_SECRET];
```
8) Authenticate a user:
```objc
[session authenticateWithUsername:@"username"
andPassword:@"password"];
```
...and you're good to go!

[CloudFS API]:http://www.bitcasa.com/cloudfs-api-docs/index.html