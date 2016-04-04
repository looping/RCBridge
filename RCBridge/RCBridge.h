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

typedef void(^MessageHandleBlock)(RCHandler *handler);

@interface RCBridge : NSObject

+ (instancetype)bridgeForWebView:(id)webView;

- (void)addMethod:(NSString *)method withHandler:(MessageHandleBlock)block;

@end

@interface RCBridge (WKWebView)

+ (WKWebViewConfiguration *)webViewConfiguration;

@end
