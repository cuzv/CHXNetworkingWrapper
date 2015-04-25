//
//  NWRequestProxy.h
//  NWNetworkingWrapper
//
//  Created by Moch Xiao on 2014-12-02.
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

#import <Foundation/Foundation.h>
#import "AFNetworkReachabilityManager.h"

@class CHXRequest;

@interface CHXRequestProxy : NSObject

+ (instancetype)sharedInstance;

/**
 *  添加请求任务
 *
 *  @param request 请求任务
 */
- (void)addRequest:(CHXRequest *)request;

/**
 *  取消请求任务
 *
 *  @param request 需要被取消的请求任务
 */
- (void)removeRequest:(CHXRequest *)request;

/**
 *  取消所有请求任务
 */
- (void)removeAllRequest;

@end



