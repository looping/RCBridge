//
//  ViewController.m
//  RCBridgeExample-Objc
//
//  Created by Looping on 4/3/16.
//  Copyright © 2016 RidgeCorn. All rights reserved.
//

#import "ViewController.h"
#import "RCBridge.h"

@import WebKit;

#define USING_WEBKIT 1

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
    self.webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:[RCBridge webViewConfiguration]];
#else
    self.webView = [[UIWebView alloc] init];
#endif
    
    NSString *randomCode = [NSString stringWithFormat:@"%@", @(arc4random() % 1024)];
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://ridgecorn.com/rcb/?_=%@", randomCode]]]];
    
    [self.view addSubview:_webView];
    
    RCBridge *bridge = [RCBridge bridgeForWebView:_webView];
    
    [bridge messageHandler:^(RCHandler *handler) {
        NSLog(@"received %@", handler.params);
        
        NSString *msg = [NSString stringWithFormat:@"%@", @(arc4random() % 1024)];
        
        [handler sendMessageBackToJS:@{
                                       @"code": @0,
                                       @"msg": msg
                                       }];
        
        NSLog(@"sent %@", msg);
    } forMethod:@"you"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
