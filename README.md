# RCBridge
A bridge for sending messages between native iOS and JavaScript in UIWebView/WKWebView.

## Installation
For now, just drag the `RCBridge ` folder into your project.

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