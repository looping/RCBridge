# RCBridge
A bridge for sending messages between native iOS and JavaScript in UIWebView/WKWebView.

## Requirements
This library requires iOS 7+ and Xcode 7+. If your project still needs support iOS 6, I’m glad to tell you [Cordova][1] and [WebViewJavascriptBridge][2] is what you are looking for.


## Installation
RCBridge supports multiple ways for integrating the library into your awesome project.

### CocoaPods
Add `pod 'RCBridge', '~> 0.1'` in your `Podfile`, then run the command `pod install` in Terminal.

### Carthage
Add `github "looping/RCBridge" ~> 0.1` in your `Cartfile `, then run the command `carthage` in Terminal to build the framework and drag the built `RCBridge.framework` into your Xcode project.

### Manual
Just drag the `RCBridge` folder into your project. Super easy, wow!


## Usage
### Swift
- Import `RCBridge` module:

		import RCBridge

*Note: If you integrate `RCBridge` manually, you should import header file in your `Objective-C Bridging Header` file.*

- Instantiate RCBridge with a UIWebView or WKWebView:

		let bridge = RCBridge(forWebView: webView)

- Add message handler:

		bridge.addMethod("you") { (handler) in
		
		}

- Send message back to JavaScript:

		let msg: [NSObject : AnyObject] = ["code": 0, "msg": "\(arc4random() % 1024)"]
		handler.sendMessageBackToJS(msg)

### Objective-C
- Import header file `RCBridge.h`:

		import "RCBridge.h"

- Instantiate RCBridge with a UIWebView or WKWebView:

		RCBridge *bridge = [RCBridge bridgeForWebView:_webView];

- Add message handler:

		[bridge addMethod:@"you" withHandler:^(RCHandler *handler) {
		
		}];

- Send message back to JavaScript:

		[handler sendMessageBackToJS:@{
			@"code": @0,
			@"msg": [NSString stringWithFormat:@"%@", @(arc4random() % 1024)]
		}];

### JavaScript
No more imports for F2E guys this time.

- Send message to native iOS:

		rcb.send("you", {"got_msg": msg}, function (args) {
		
		})

[1]:	https://github.com/apache/cordova-ios
[2]:	https://github.com/marcuswestin/WebViewJavascriptBridge