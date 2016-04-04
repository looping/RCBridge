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


static NSDictionary * str2JSONObj(NSString *string) {
    return [NSJSONSerialization JSONObjectWithData:[string dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
}


@interface RCBridge ()
@property (nonatomic) NSMutableDictionary <NSString *, MessageHandleBlock> *messageHandlers;
@property (nonatomic, weak) id webView;

+ (NSString *)rcbSourceScript;

@end

@interface RCBridgeManager : NSObject
@property (nonatomic) NSMutableDictionary *bridges;

+ (void)addBridge:(RCBridge *)bridge;

+ (void)removeBridge:(RCBridge *)bridge;

+ (RCBridge *)bridgeForWebView:(id)webView;

+ (UIWebView *)targetWebViewWithJSContext:(JSContext *)context;

+ (BOOL)handleMessage:(NSString *)msg fromWebView:(id)webView;

+ (BOOL)injectScriptToContext:(JSContext *)context;

@end

@implementation RCBridgeManager

+ (instancetype)sharedInstance {
    static RCBridgeManager *sharedManager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[RCBridgeManager alloc] init];
        sharedManager.bridges = [@{} mutableCopy];
    });
    
    return sharedManager;
}

+ (void)addBridge:(RCBridge *)bridge {
    NSString *rcbId = [NSString stringWithFormat:@"rcb:%p", bridge.webView];
    
    if (bridge && rcbId) {
        [[RCBridgeManager sharedInstance].bridges setObject:bridge forKey:rcbId];
    }
}

+ (void)removeBridge:(RCBridge *)bridge {
    NSString *rcbId = [NSString stringWithFormat:@"rcb:%p", bridge.webView];
    
    if (bridge && rcbId) {
        [[RCBridgeManager sharedInstance].bridges removeObjectForKey:rcbId];
    }
}

+ (RCBridge *)bridgeForWebView:(id)webView {
    NSString *rcbId = [NSString stringWithFormat:@"rcb:%p", webView];
    
    return [[RCBridgeManager sharedInstance].bridges objectForKey:rcbId];
}

+ (UIWebView *)targetWebViewWithJSContext:(JSContext *)context {
    NSArray *allBridges = [RCBridgeManager sharedInstance].bridges.allValues;
    UIWebView *targetWebView = nil;
    NSString *randomCode = [NSString stringWithFormat:@"%@", @(arc4random() % 1024)];
    NSString *flagName = [NSString stringWithFormat:@"rcbId%@", randomCode];
    
    NSString *script = [NSString stringWithFormat:@"var %@ = '%@'", flagName, randomCode];
    
    [context evaluateScript:script];
    
    for (RCBridge *bridge in allBridges) {
        if ([bridge.webView isKindOfClass:[UIWebView class]]) {
            UIWebView *webView = bridge.webView;
            
            if ([[webView stringByEvaluatingJavaScriptFromString:flagName] isEqualToString:randomCode]) {
                targetWebView = webView;
                break;
            }
        }
    }
    
    return targetWebView;
}

+ (BOOL)handleMessage:(NSString *)msg fromWebView:(id)webView {
    BOOL handled = YES;
    
    RCBridge *bridge = [RCBridgeManager bridgeForWebView:webView];
    
    if (bridge) {
        RCHandler *handler = [[RCHandler alloc] initWithMessage:str2JSONObj(msg) inWebView:webView];
        MessageHandleBlock handleBlock = [bridge.messageHandlers objectForKey:handler.method];
        
        if (handleBlock) {
            handleBlock(handler);
        }
    } else {
        handled = NO;
    }
    
    return handled;
}

+ (BOOL)injectScriptToContext:(JSContext *)context {
    BOOL injected = YES;
    
    UIWebView *targetWebView = [RCBridgeManager targetWebViewWithJSContext:context]; // [self valueForKeyPath:@"target.uiWebView"];
    RCBridge *bridge = [RCBridgeManager bridgeForWebView:targetWebView];
    
    if (bridge) {
        context[@"rcb_sendMessageToNative"] = ^BOOL(NSString *cmd) {
            return [RCBridgeManager handleMessage:cmd fromWebView:bridge.webView];
        };
        
        [context evaluateScript:[RCBridge rcbSourceScript]];
    } else {
        injected = NO;
    }
    
    return injected;
}

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

+ (NSString *)rcbSourceScript {
    return [NSString stringWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"RCBridge" ofType:@"js"] encoding:NSUTF8StringEncoding error:nil];
}

+ (instancetype)bridgeForWebView:(id)webView {
    RCBridge *bridge = [[RCBridge alloc] init];
    bridge.webView = webView;
    
    [RCBridgeManager addBridge:bridge];
    
    return bridge;
}

- (void)addMethod:(NSString *)method withHandler:(MessageHandleBlock)block {
    [self.messageHandlers setObject:block forKey:method];
}

- (void)removeMethod:(NSString *)method {
    [self.messageHandlers removeObjectForKey:method];
}

@end

@implementation RCBridge (WKWebView)

+ (WKWebViewConfiguration *)webViewConfiguration {
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    configuration.userContentController = [[WKUserContentController alloc] init];
    RCNativeServer *nativeServer = [[RCNativeServer alloc] init];
    [configuration.userContentController addScriptMessageHandler:nativeServer name:@"nativeServer"];
    WKUserScript *script = [[WKUserScript alloc] initWithSource:[self rcbSourceScript] injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:YES];
    [configuration.userContentController addUserScript:script];
    
    return configuration;
}

@end

@implementation NSObject (RCBridge)

- (void)webView:(id)webView didCreateJavaScriptContext:(JSContext *)context forFrame:(id)frame {
    [RCBridgeManager injectScriptToContext:context];
}

@end
