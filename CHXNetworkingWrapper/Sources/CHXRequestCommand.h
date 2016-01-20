//
//  CHXRequestCommand.h
//  CHXNetworkingWrapper
//
//  Created by Moch Xiao on 2015-04-19.
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

#import <Foundation/Foundation.h>
#import "AFNetworkReachabilityManager.h"
#import "CHXRequestCommandProtocol.h"

@class CHXRequest;

@interface CHXRequestCommand : NSObject <CHXRequestCommandProtocol>

/// CHXRequestCommand shared instance
+ (instancetype)sharedInstance;

/// When YES, will print request info and response info on terminal
@property (nonatomic, assign) BOOL debugMode;

/// Network not reachable description
@property (nonatomic, copy) NSString *networkNotReachableDescription;

/// Max concurent operation count, default is 4
@property (nonatomic, assign) NSUInteger maxConcurrentOperationCount;

/// Sets a callback to be executed when the network availability of the `baseURL` host changes.
- (void)setReachabilityStatusChangeBlock:(void (^)(AFNetworkReachabilityStatus status))block;

@end



