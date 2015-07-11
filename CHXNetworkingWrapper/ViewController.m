//
//  ViewController.m
//  CHXNetworkingWrapper
//
//  Created by Moch Xiao on 2015-04-25.
//  Copyright (c) 2014 Moch Xiao (https://github.com/atcuan).
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
#import "CHXRequest+AsynchronouslyRequest.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self testApi];
}

- (void)testApi {
    
    CHXPromoteProductListRequest *request = [[CHXPromoteProductListRequest alloc] initWithNumber:3 type:@"index_best"];
    [request startRequestWithSuccessHandler:^(CHXRequest *request, id responseResult) {
        NSLog(@"%@", responseResult);
        [[[UIAlertView alloc] initWithTitle:@"" message:@"Success" delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil] show];
    } failureHandler:^(CHXRequest *request, id reponseMessage) {
        NSLog(@"%@", reponseMessage);
        [[[UIAlertView alloc] initWithTitle:@"" message:@"Failure" delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil] show];
    }];
    
//    [AFHTTPSessionManager manager].responseSerializer = [AFHTTPResponseSerializer serializer];
//    [[AFHTTPSessionManager manager] POST:@"http://www.163.com" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
//        NSLog(@"OK");
//        [[[UIAlertView alloc] initWithTitle:@"" message:@"Success" delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil] show];
//    } failure:^(NSURLSessionDataTask *task, NSError *error) {
//        NSLog(@"NO");
//        [[[UIAlertView alloc] initWithTitle:@"" message:@"Failure" delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil] show];
//    }];
    
}

- (void)testDownload {
    CHXDownLoadRequest *down = [[CHXDownLoadRequest new] initWithDownloadProgress:^(CGFloat progress) {
        NSLog(@"progress = %f", progress);
    }];
    [down startRequestWithSuccess:^(id responseObject) {
        NSLog(@"%@", responseObject);
        dispatch_async(dispatch_get_main_queue(), ^{
        });
        
    } failure:^(id errorMessage) {
        NSLog(@"%@", errorMessage);
        dispatch_async(dispatch_get_main_queue(), ^{
            
        });
    }];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//    [self testDownload];
    [self testApi];
}
@end
