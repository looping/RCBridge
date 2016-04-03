//
//  RCHandler.h
//  RCBridge
//
//  Created by Looping on 4/3/16.
//  Copyright © 2016 RidgeCorn. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RCHandler : NSObject
@property (nonatomic, readonly) NSString *method;
@property (nonatomic, readonly) NSDictionary *params;

- (instancetype)initWithMessage:(NSDictionary *)message inWebView:(id)webView;

- (void)sendMessageBackToJS:(NSDictionary *)message;

@end
