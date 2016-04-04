# RCBridge
A bridge for sending messages between native iOS and JavaScript in UIWebView/WKWebView.

## Installation
RCBridge supports multiple ways for integrating the library into your awesome project.

### CocoaPods
Add `pod 'RCBridge', '~> 0.1'` in your `Podfile`, then run the command `pod install` in Terminal.

### Carthage
Add `github "looping/RCBridge" ~> 0.1` in your `Cartfile `, then run the command `carthage` in Terminal to build the framework and drag the built `RCBridge.framework` into your Xcode project.

### Manual
Just drag the `RCBridge` folder into your project. Super easy, wow!

## Requirements
We requires iOS 7+ and Xcode 7+.

## Usage
- Import the header file `RCBridge.h`:

		import "RCBridge.h"

- Instantiate RCBridge with a UIWebView or WKWebView:

		RCBridge *bridge = [RCBridge bridgeForWebView:_webView];

- Add message handler:

		[bridge messageHandler:^(RCHandler *handler) {
		
		} forMethod:@"you"];

- Send message back to JavaScript:

		[handler sendMessageBackToJS:@{
		    @"code": @0,
		}];

- About JavaScript, it is easy to use:

		rcb.send("you", {"got_msg": msg}, function (args) {
		
		})