//
//  CHXRequestHoster.m
//  CHXNetworkingWrapper
//
//  Created by Moch Xiao on 1/20/16.
//  Copyright © @2014 Moch Xiao (https://github.com/cuzv).
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

#import "CHXRequest.h"
#import "CHXCommandability.h"
#import "CHXResponseable.h"
#import "CHXRequestable.h"
#import "CHXRequest+Internal.h"

@interface CHXRequest ()

@property (nonatomic, weak, readwrite) id<CHXRequestable, CHXResponseable> setup;
@property (nonatomic, strong, readwrite) id<CHXCommandability> command;
/// The event notify queue
@property (nonatomic, strong) dispatch_queue_t queue;

@end

@implementation CHXRequest

#if DEBUG
- (void)dealloc {
    if (self.printDebugInfo) {
        NSLog(@"~~~~~~~~~~~%s~~~~~~~~~~~", __FUNCTION__);
    }
}
#endif

- (nullable instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    if (![self conformsToProtocol:@protocol(CHXRequestable)] ||
        ![self conformsToProtocol:@protocol(CHXResponseable)]) {
        [NSException raise:@"Request must conform `CHXRequestable` and `CHXResponseable` " format:@""];
    }
    
    _setup = (id<CHXRequestable, CHXResponseable>)self;
    _command = (id<CHXCommandability>)[self.setup requestCommand];
    _printDebugInfo = YES;
    
    return self;
}

- (nonnull CHXRequest *)start {
    [self _initializeQueue];
    [self.command injectRequest:self];
    
    return self;
}

- (nonnull CHXRequest *)cancel {
    [self.command removeRequest];
    
    return self;
}

#pragma mark - 

- (void)_initializeQueue {
    if (self.queue) {
        return;
    }
    
    self.queue = ({
        NSString *queueLabel = [NSString stringWithFormat:@"xiao.moch.queueidentifier.%zd", [self hash]];
        dispatch_queue_t queue = dispatch_queue_create([queueLabel UTF8String], DISPATCH_QUEUE_SERIAL);
        dispatch_suspend(queue);
        queue;
    });
}

- (void)notifyComplete {
    if (self.queue) {
        dispatch_resume(self.queue);
    }
}

#pragma mark - 

- (nonnull CHXRequest *)completionHandler:(nullable RequestCompletionHandler)completionHandler {
    dispatch_async(self.queue, ^{
        if (self.deliverOnMainThread) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler(self, self.responseObject);
            });
        } else {
            completionHandler(self, self.responseObject);
        }
    });

    return self;
}

- (nonnull CHXRequest *)successHandler:(nullable RequestSuccessHandler)successHandler {
    dispatch_async(self.queue, ^{
        if (!self.responseSuccess) {
            return;
        }
        if (self.deliverOnMainThread) {
            dispatch_async(dispatch_get_main_queue(), ^{
                successHandler(self, self.responseResult);
            });
        } else {
            successHandler(self, self.responseResult);
        }
    });

    return self;
}

- (nonnull CHXRequest *)failureHandler:(nullable RequestFailureHandler)failureHandler {
    dispatch_async(self.queue, ^{
        if (self.responseSuccess) {
            return;
        }
        if (self.deliverOnMainThread) {
            dispatch_async(dispatch_get_main_queue(), ^{
                failureHandler(self, self.responseMessage);
            });
        } else {
            failureHandler(self, self.responseMessage);
        }
    });

    return self;
}

- (nonnull CHXRequest *)startRequestWithSuccessHandler:(nullable RequestSuccessHandler)successHandler
                                        failureHandler:(nullable RequestFailureHandler)failureHandler {
    [self start];
    
    dispatch_async(self.queue, ^{
        if (self.deliverOnMainThread) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.responseSuccess) {
                    successHandler(self, self.responseResult);
                } else {
                    failureHandler(self, self.responseMessage);
                }
            });
        } else {
            if (self.responseSuccess) {
                successHandler(self, self.responseResult);
            } else {
                failureHandler(self, self.responseMessage);
            }
        }
    });

    return self;
}

@end
