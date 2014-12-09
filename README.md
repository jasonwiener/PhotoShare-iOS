# PhotoShare

PhotoShare is a photo sharing app built upon the Bitcasa CloudFS platform SDK. By using PhotoShare you can upload, share photos with your friends and “like” photos that you find interesting. 
This implementation of the PhotoShare app has been done using the [CloudFS iOS](https://github.com/bitcasa/CloudFS-iOS) SDK on [iOS](http://developer.apple.com). 



## Installation

### 1. Download
First you need to clone the *PhotoShare-iOS* project files to your workspace:

    $ cd /path/to/your/workspace
    $ git clone git@github.com:bitcasa/PhotoShare-iOS.git projectname  
    $ cd projectname

### 2. Requirements
* iOS SDK 8.0 or above.
* Xcode 6 or above.

### 3. Tweaks
#### CloudFS Settings
For you to use the PhotoShare app with CloudFS, you need to enter your CloudFS related credentials in the app configuration file. The file location and the related settings are as follows:

    $ \PhotoShare\Supporting Files\BitcasaConfig.plist

```   
<plist version="1.0">
<dict>
    <key>BC_API_SERVER_URL</key>
    <string>xxxx</string>
    <key>BC_CLIENT_ID</key>
    <string>xxxx</string>
    <key>BC_SECRET</key>
    <string>xxxx</string>
    <key>BC_USER_REGISTRATION_URL</key>
    <string>xxxx</string>
    <key>BC_USER_AUTH_URL</key>
    <string>xxxx</string>
    <key>BC_APP_ACCOUNT_USER</key>
    <string>xxxx</string>
    <key>BC_APP_ACCOUNT_PASSWORD</key>
    <string>xxxx</string>
</dict>
</plist>
```

More information on these variable and account creation can be found in our PhotoShare-iOS [documentation](#)

### 4. Start development
Once all these steps are carried out you will be able to start tweaking and changing the app to discover the posibilities provided by the CloudFS SDK and iOS.


