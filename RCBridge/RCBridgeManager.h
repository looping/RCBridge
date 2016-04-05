//
//  RCBridgeManager.h
//  RCBridge
//
//  Created by Looping on 4/6/16.
//  Copyright © 2016 RidgeCorn. All rights reserved.
//

@import Foundation;

@class RCBridge, JSContext;

@interface RCBridgeManager : NSObject

+ (void)addBridge:(RCBridge *)bridge;

+ (void)removeBridge:(RCBridge *)bridge;

+ (RCBridge *)bridgeForWebView:(id)webView;

+ (BOOL)handleMessage:(NSString *)msg fromWebView:(id)webView;

+ (BOOL)injectRCBridgeScriptToContext:(JSContext *)context;

+ (NSString *)rcbSourceScript;

@end
