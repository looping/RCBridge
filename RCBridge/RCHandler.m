//
//  RCHandler.m
//  RCBridge
//
//  Created by Looping on 4/3/16.
//  Copyright © 2016 RidgeCorn. All rights reserved.
//

#import "RCHandler.h"
#import <UIKit/UIKit.h>
@import WebKit;

@interface RCHandler ()
@property (nonatomic) NSString *callback;
@property (nonatomic, weak) id webView;

@end

@implementation RCHandler

- (instancetype)initWithMessage:(NSDictionary *)message inWebView:(id)webView {
    if (self = [super init]) {
        _method = [message objectForKey:@"method"];
        _params = [message objectForKey:@"params"];
        _callback = [message objectForKey:@"callback"];
        _webView = webView;
    }
    
    return self;
}

- (void)sendMessageBackToJS:(NSDictionary *)message {
    if (_callback && message) {
        NSDictionary *cmd = @{
                              @"method": _callback,
                              @"params": message
                              };
        
        NSString *script = [NSString stringWithFormat: @"rcb.handleMessageFromNative('%@')", [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:cmd options:kNilOptions error:nil] encoding:NSUTF8StringEncoding]];
        
        if ([_webView isKindOfClass:[UIWebView class]]) {
            [(UIWebView *)_webView stringByEvaluatingJavaScriptFromString:script];
        } else if ([_webView isKindOfClass:[WKWebView class]]) {
            [(WKWebView *)_webView evaluateJavaScript:script completionHandler:nil];
        }
    }
}

@end
