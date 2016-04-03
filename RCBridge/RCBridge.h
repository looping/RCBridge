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

+ (void)bridgingInWebView:(id)webView;

+ (WKWebViewConfiguration *)webViewConfiguration;

+ (void)messageHandler:(MessageHandleBlock)block forMethod:(NSString *)method;

@end
