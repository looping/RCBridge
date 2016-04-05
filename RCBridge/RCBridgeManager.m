//
//  RCBridgeManager.m
//  RCBridge
//
//  Created by Looping on 4/6/16.
//  Copyright © 2016 RidgeCorn. All rights reserved.
//

#import "RCBridgeManager.h"
#import "RCBridge.h"

@import UIKit;
@import JavaScriptCore;

static NSDictionary * str2JSONObj(NSString *string) {
    return [NSJSONSerialization JSONObjectWithData:[string dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
}

static NSString * rcbId4Obj(id obj) {
    return [NSString stringWithFormat:@"rcb:%p", obj];
}

@interface RCBridgeManager ()
@property (nonatomic) NSMutableDictionary *bridges;

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
    NSString *rcbId = rcbId4Obj(bridge.bridgedWebView);
    
    if (bridge && rcbId) {
        [[RCBridgeManager sharedInstance].bridges setObject:bridge forKey:rcbId];
    }
}

+ (void)removeBridge:(RCBridge *)bridge {
    NSString *rcbId = rcbId4Obj(bridge.bridgedWebView);
    
    if (bridge && rcbId) {
        [[RCBridgeManager sharedInstance].bridges removeObjectForKey:rcbId];
    }
}

+ (RCBridge *)bridgeForWebView:(id)webView {
    NSString *rcbId = rcbId4Obj(webView);
    
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
        if ([bridge.bridgedWebView isKindOfClass:[UIWebView class]]) {
            UIWebView *webView = bridge.bridgedWebView;
            
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
        RCBMessageHandlerBlock handlerBlock = [bridge handlerForMethod:handler.method];
        
        if (handlerBlock) {
            handlerBlock(handler);
        }
    } else {
        handled = NO;
    }
    
    return handled;
}

+ (BOOL)injectRCBridgeScriptToContext:(JSContext *)context {
    BOOL injected = YES;
    
    UIWebView *targetWebView = [RCBridgeManager targetWebViewWithJSContext:context];
    RCBridge *bridge = [RCBridgeManager bridgeForWebView:targetWebView];
    
    if (bridge) {
        context[@"rcb_sendMessageToNative"] = ^BOOL(NSString *cmd) {
            return [RCBridgeManager handleMessage:cmd fromWebView:bridge.bridgedWebView];
        };
        
        [context evaluateScript:[self rcbSourceScript]];
    } else {
        injected = NO;
    }
    
    return injected;
}

+ (NSString *)rcbSourceScript {
    return [NSString stringWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"RCBridge" ofType:@"js"] encoding:NSUTF8StringEncoding error:nil];
}

@end
