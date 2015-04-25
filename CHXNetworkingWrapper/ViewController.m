//
//  ViewController.m
//  CHXNetworkingWrapper
//
//  Created by Moch Xiao on 4/25/15.
//  Copyright (c) 2015 Moch Xiao. All rights reserved.
//

#import "ViewController.h"
#import "CHXPromoteProductListRequest.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self testApi];
}

- (void)testApi {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        CHXPromoteProductListRequest *request = [[CHXPromoteProductListRequest alloc] initWithNumber:3 type:@"index_best"];
        [request startRequestWithSuccess:^(id responseObject) {
            NSLog(@"%@", responseObject);
            dispatch_async(dispatch_get_main_queue(), ^{
                
            });
        } failue:^(id errorMessage) {
            NSLog(@"%@", errorMessage);
            dispatch_async(dispatch_get_main_queue(), ^{
                
            });
        }];
    });
}
@end
