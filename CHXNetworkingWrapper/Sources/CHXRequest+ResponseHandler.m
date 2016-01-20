//
//  CHXRequest+ResponseHandler.m
//  CHXNetworkingWrapper
//
//  Created by Moch Xiao on 7/11/15.
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

#import "CHXRequest+ResponseHandler.h"
#import "CHXRequest+CHXRequestCommand.h"
#import "CHXRequest+Private.h"

@interface CHXRequest ()
@end

#pragma mark -

@implementation CHXRequest (ResponseHandler)

#pragma mark Deprecated

- (CHXRequest *)successCompletionResponse:(RequestSuccessCompletionBlock)requestSuccessCompletionBlock {
    dispatch_async(self.queue, ^{
        requestSuccessCompletionBlock(self.responseResult);
    });
    
    return self;
}

- (CHXRequest *)failureCompletionResponse:(RequestFailureCompletionBlock)requestFailureCompletionBlock {
    dispatch_async(self.queue, ^{
        requestFailureCompletionBlock(self.responseMessage);
    });
    
    return self;
}

- (CHXRequest *)completionResponse:(RequestCompletionBlock)requestCompletionBlock {
    dispatch_async(self.queue, ^{
        requestCompletionBlock(self.responseResult, self.responseMessage);
    });
    
    return self;
}

#pragma mark - Preferred

- (CHXRequest *)completionHandler:(RequestCompletionHandler)completionHandler {
    dispatch_async(self.queue, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            completionHandler(self, self.responseObject);
        });
    });
    
    return self;
}

- (CHXRequest *)successHandler:(RequestSuccessHandler)successHandler {
    dispatch_async(self.queue, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            successHandler(self, self.responseResult);
        });
    });
    
    return self;
}

- (CHXRequest *)failureHnadler:(RequestFailureHandler)failureHnadler {
    dispatch_async(self.queue, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            failureHnadler(self, self.responseMessage);
        });
    });
    
    return self;
}


- (CHXRequest *)startRequestWithSuccess:(RequestSuccessCompletionBlock)requestSuccessCompletionBlock
                                 failure:(RequestFailureCompletionBlock)requestFailureCompletionBlock
                                 __attribute__((deprecated("use startRequestWithSuccessHandler:failureHandler instead"))) {
    [self startRequest];

    dispatch_async(self.queue, ^{
        if (self.responseSuccess) {
            requestSuccessCompletionBlock(self.responseResult);
        } else {
            requestFailureCompletionBlock(self.responseMessage);
        }
    });
    
    return self;
}

- (CHXRequest *)startRequestWithSuccessHandler:(RequestSuccessHandler)successHandler
                                failureHandler:(RequestFailureHandler)failureHandler {
    [self startRequest];
    
    dispatch_async(self.queue, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.responseSuccess) {
                successHandler(self, self.responseResult);
            } else {
                failureHandler(self, self.responseMessage);
            }
        });
    });
    
    return self;
}

@end
