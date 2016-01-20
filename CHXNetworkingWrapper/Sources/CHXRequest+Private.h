//
//  CHXRequest+Private.h
//  CHXNetworkingWrapper
//
//  Created by Moch Xiao on 7/14/15.
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
#import "CHXRequest.h"

@interface CHXRequest ()

/// This transfer protocol methods response to subclass
@property (nonatomic, weak, readonly) id <CHXRequestConstructProtocol, CHXRequestRetrieveProtocol> subclass;

/// When networking is not reachable, retry after 1s, this record how many times have tried.
@property (nonatomic, assign) NSUInteger currentRetryCount;

/// Hold on request task, only invoke by `CHXRequestCommand`
@property (nonatomic, strong) NSURLSessionTask *requestSessionTask;

/// The event notify queue
@property (nonatomic, strong) dispatch_queue_t queue;

/// Initialze dispatch_queue
- (CHXRequest *)initializeQueueIfNeeded;

/// Notify the request is complete
/// Only invoke by `CHXRequestCommand`
/// No matter the request is success or failure, will invoke this method
- (CHXRequest *)notifyComplete;

@end

