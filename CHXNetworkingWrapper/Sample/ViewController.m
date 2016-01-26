//
//  ViewController.m
//  CHXNetworkingWrapper
//
//  Created by Moch Xiao on 2015-04-25.
//  Copyright (c) 2014 Moch Xiao (https://github.com/cuzv).
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "ViewController.h"
#import "CHXPromoteProductListRequest.h"
#import "CHXDownLoadRequest.h"
#import "CHXNetworkingWrapper.h"

@interface ViewController () <UITableViewDelegate, UICollectionViewDelegate>

@end

@implementation ViewController

#pragma mark - respondsToSelector

- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:CHXNetworkingReachabilityDidChangeNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        NSLog(@"%@", note.userInfo);
    }];
    
}

- (void)testApi {
    CHXPromoteProductListRequest *request = [[CHXPromoteProductListRequest alloc] initWithNumber:3 type:@"index_best"];
    [request startRequestWithSuccessHandler:^(CHXRequest *request, id responseResult) {
        NSLog(@"responseResult: %@", responseResult);
    } failureHandler:^(CHXRequest *request, id responseMessage) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[[UIAlertView alloc] initWithTitle:@"" message:responseMessage delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
        });
    }];
    if (arc4random() % 2) {
        [request cancel];
    }
}

- (void)testDownload {
    CHXDownLoadRequest *down = [[CHXDownLoadRequest new] initWithDownloadProgress:^(CGFloat progress) {
        NSLog(@"progress = %f", progress);
    }];
    [down startRequestWithSuccessHandler:^(CHXRequest *request, id responseResult) {
        NSLog(@"%@", responseResult);
    } failureHandler:^(CHXRequest *request, id responseMessage) {
        NSLog(@"responseMessage: %@", responseMessage);
    }];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//    [self testDownload];
    
//    for (int i = 0; i < 10; i++) {
//        sleep(0.5);
//        [self testApi];
//    }

    [self testApi];
}


@end
