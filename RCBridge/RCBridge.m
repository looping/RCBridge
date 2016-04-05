//
//  RCBridge.m
//  RCBridge
//
//  Created by Looping on 4/3/16.
//  Copyright © 2016 RidgeCorn. All rights reserved.
//

#import "RCBridge.h"
#import "RCBridgeManager.h"

@import JavaScriptCore;
@import WebKit;

@interface RCBridge ()
@property (nonatomic) NSMutableDictionary <NSString *, RCBMessageHandlerBlock> *messageHandlers;
@property (nonatomic, weak) id webView;

@end


@interface RCNativeServer : NSObject <WKScriptMessageHandler>

@end

@implementation RCNativeServer

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    [RCBridgeManager handleMessage:message.body fromWebView:message.webView];
}

@end

@implementation RCBridge

- (instancetype)init {
    if (self = [super init]) {
        _messageHandlers = [@{} mutableCopy];
    }
    
    return self;
}

+ (instancetype)bridgeForWebView:(id)webView {
    RCBridge *bridge = [[RCBridge alloc] init];
    bridge.webView = webView;
    
    [RCBridgeManager addBridge:bridge];
    
    return bridge;
}

- (void)addMethod:(NSString *)method withHandler:(RCBMessageHandlerBlock)handlerBlock {
    [self.messageHandlers setObject:handlerBlock forKey:method];
}

- (void)removeMethod:(NSString *)method {
    [self.messageHandlers removeObjectForKey:method];
}

- (id)bridgedWebView {
    return _webView;
}

- (RCBMessageHandlerBlock)handlerForMethod:(NSString *)method {
    return [_messageHandlers objectForKey:method];
}

@end

@implementation RCBridge (WKWebView)

+ (WKWebViewConfiguration *)webViewConfiguration {
    static WKWebViewConfiguration *configuration = nil;
    
    if (configuration == nil) {
        configuration = [[WKWebViewConfiguration alloc] init];
        
        RCNativeServer *nativeServer = [[RCNativeServer alloc] init];
        
        [configuration.userContentController addScriptMessageHandler:nativeServer name:@"nativeServer"];
        
        WKUserScript *script = [[WKUserScript alloc] initWithSource:[RCBridgeManager rcbSourceScript] injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:YES];
        
        [configuration.userContentController addUserScript:script];
    }
    
    return configuration;
}

@end

@implementation NSObject (RCBridge)

- (void)webView:(id)webView didCreateJavaScriptContext:(JSContext *)context forFrame:(id)frame {
    // Using [self valueForKeyPath:@"target.uiWebView"] can also get target webView.
    
    [RCBridgeManager injectRCBridgeScriptToContext:context];
}

@end
