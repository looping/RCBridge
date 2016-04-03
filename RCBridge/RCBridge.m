//
//  RCBridge.m
//  RCBridge
//
//  Created by Looping on 4/3/16.
//  Copyright © 2016 RidgeCorn. All rights reserved.
//

#import "RCBridge.h"

@import JavaScriptCore;
@import WebKit;

@class WebView, WebFrame;

static NSDictionary * str2JSONObj(NSString *string) {
    return [NSJSONSerialization JSONObjectWithData:[string dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
}

@interface RCBridge ()
@property (nonatomic) NSMutableDictionary <NSString *, MessageHandleBlock> *messageHandlers;
@property (nonatomic, weak) id webView;

+ (instancetype)sharedBridge;

@end

@interface RCNativeServer : NSObject <WKScriptMessageHandler>

@end

@implementation RCNativeServer

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    RCHandler *handler = [[RCHandler alloc] initWithMessage:str2JSONObj(message.body) inWebView:[RCBridge sharedBridge].webView];
    
    [[RCBridge sharedBridge].messageHandlers objectForKey:handler.method](handler);
}

@end

@implementation RCBridge

+ (instancetype)sharedBridge {
    static RCBridge *bridge;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        bridge = [[RCBridge alloc] init];
        
        bridge.messageHandlers = [@{} mutableCopy];
    });
    
    return bridge;
}

+ (NSString *)rcbSourceScript {
    return [NSString stringWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"RCBridge" ofType:@"js"] encoding:NSUTF8StringEncoding error:nil];
}

+ (void)bridgingInWebView:(id)webView {
    [RCBridge sharedBridge].webView = webView;
}

+ (WKWebViewConfiguration *)webViewConfiguration {
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    configuration.userContentController = [[WKUserContentController alloc] init];
    RCNativeServer *nativeServer = [[RCNativeServer alloc] init];
    [configuration.userContentController addScriptMessageHandler:nativeServer name:@"nativeServer"];
    WKUserScript *script = [[WKUserScript alloc] initWithSource:[[self class] rcbSourceScript] injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:YES];
    [configuration.userContentController addUserScript:script];
    
    return configuration;
}

+ (void)messageHandler:(MessageHandleBlock)block forMethod:(NSString *)method {
    [[RCBridge sharedBridge].messageHandlers setObject:block forKey:method];
}

@end

@implementation NSObject (RCBridge)

- (void)webView:(WebView *)webView didCreateJavaScriptContext:(JSContext *)context forFrame:(WebFrame *)frame {
    if ([RCBridge sharedBridge].webView) {
        context[@"rcb_sendMessageToNative"] = ^(NSString *cmd) {
            RCHandler *handler = [[RCHandler alloc] initWithMessage:str2JSONObj(cmd) inWebView:[RCBridge sharedBridge].webView];
            
            [[RCBridge sharedBridge].messageHandlers objectForKey:handler.method](handler);
        };
        
        [context evaluateScript:[[RCBridge class] rcbSourceScript]];
    }
}

@end
