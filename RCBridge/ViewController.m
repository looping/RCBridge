//
//  ViewController.m
//  RCBridge
//
//  Created by Looping on 4/3/16.
//  Copyright © 2016 RidgeCorn. All rights reserved.
//

#import "ViewController.h"
@import JavaScriptCore;
@import WebKit;

#define USING_WEBKIT 1

@class WebView, WebFrame;

@implementation NSObject (RCBridge)

+ (NSString *)rcbSourceScript {
    return [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"RCBridge" ofType:@"js"] encoding:NSUTF8StringEncoding error:nil];
}

- (void)webView:(WebView *)webView didCreateJavaScriptContext:(JSContext *)context forFrame:(WebFrame *)frame {
    context[@"rcb_sendMessageToNative"] = ^NSString *(NSString *cmd) {
        NSLog(@"%@", cmd);
        return @"0";
    };
    
    [context evaluateScript:[[self class] rcbSourceScript]];
}

@end

@interface RCNativeServer : NSObject <WKScriptMessageHandler>

@end

@implementation RCNativeServer

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    NSLog(@"%@", message.body);
}

@end

@interface ViewController ()

#if USING_WEBKIT
@property (nonatomic) WKWebView *webView;
#else
@property (nonatomic) UIWebView *webView;
#endif

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
#if USING_WEBKIT
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    configuration.userContentController = [[WKUserContentController alloc] init];
    RCNativeServer *nativeServer = [[RCNativeServer alloc] init];
    [configuration.userContentController addScriptMessageHandler:nativeServer name:@"nativeServer"];
    WKUserScript *script = [[WKUserScript alloc] initWithSource:[[self class] rcbSourceScript] injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:YES];
    [configuration.userContentController addUserScript:script];
    self.webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:configuration];
#else
    self.webView = [[UIWebView alloc] init];
#endif
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://ridgecorn.com/rcb/"]]];
    
    [self.view addSubview:self.webView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
