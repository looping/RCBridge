//
//  RCBridge.h
//  RCBridge
//
//  Created by Looping on 4/3/16.
//  Copyright © 2016 RidgeCorn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCHandler.h"

@class WKWebViewConfiguration;

typedef void(^RCBMessageHandlerBlock)(RCHandler *handler);

@interface RCBridge : NSObject

+ (instancetype)bridgeForWebView:(id)webView;

- (void)addMethod:(NSString *)method withHandler:(RCBMessageHandlerBlock)handlerBlock;

- (void)removeMethod:(NSString *)method;

@end

@interface RCBridge (WKWebView)

+ (WKWebViewConfiguration *)webViewConfiguration;

@end
