# APNsPayloadViewer

This application purpose show a payload from your sended Push Notification.



# How to use

Clone this project and open the file `APNsPayloadViewer.xcodproj`.

## Set the Topics
The `Topics.xcconfig` should be in the red.
File -> New -> File... -> Configuration Settings file -> type `Topics`, Follow these steps to create a `Topics.xcconfig`. 

Describe your `PRODUCT_BUNDLE_IDENTIFIER` and `DEVELOPMENT_TEAM` in the xcconfig. 
Here's example.
```makefile
PRODUCT_BUNDLE_IDENTIFIER=your.application.bundle.id
DEVELOPMENT_TEAM=XXXXXXXXXX
```
The `APNsPayloadViewer` is now ready to be built.

## Get a deviceToken

Launch the app on the iOS Device(not simurator).
Immediately after startup, you will be asked for permission to push.
When the deviceToken is ready, you can press the button on the right side of the navigation bar.
Tap the button. The deviceToken is copied to the clipboard.

## Receive a push

We have the `Topic` (Bundle ID) and the `deviceToken`. Now we can send Push to the app.
Send Push to your app in any way you like.


In the project's root directory, there is a `sendpush.sh` that sends a request to the APNs Server via cURL.
You should modify the Properties in the shell to suit your environment. 
Here is example of execute.
```bash
$ sendpush.sh { device token }
```

On success, you will see the latest push in the list in the Viewer.
Tap on a cell in the table. You can see the contents of the payload that should have been sent to you.


Use it when you feel strongly that you want to see Push on a real device.😜
Have fun!



# Acknowledgement

* [asensei/AnyCodable](https://github.com/asensei/AnyCodable)
