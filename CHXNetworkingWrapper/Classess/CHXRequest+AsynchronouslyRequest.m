//
//  CHXRequest+AsynchronouslyRequest.m
//  CHXNetworkingWrapper
//
//  Created by Moch Xiao on 7/11/15.
//  Copyright (c) 2015 Moch Xiao. All rights reserved.
//

#import "CHXRequest+AsynchronouslyRequest.h"
#import "CHXRequest+CHXRequestProxy.h"

@interface CHXRequest ()
@property (nonatomic, strong) dispatch_queue_t queue;
@end


#pragma mark -

@implementation CHXRequest (AsynchronouslyRequest)

#pragma mark Deprecated

- (CHXRequest *)successCompletionResponse:(RequestSuccessCompletionBlock)requestSuccessCompletionBlock {
    dispatch_async(self.queue, ^{
        requestSuccessCompletionBlock(self.responseResult);
    });
    
    return self;
}

- (CHXRequest *)failureCompletionResponse:(RequestFailureCompletionBlock)requestFailureCompletionBlock {
    dispatch_async(self.queue, ^{
        requestFailureCompletionBlock(self.reponseMessage);
    });
    
    return self;
}

- (CHXRequest *)completionResponse:(RequestCompletionBlock)requestCompletionBlock {
    dispatch_async(self.queue, ^{
        requestCompletionBlock(self.responseResult, self.reponseMessage);
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
            failureHnadler(self, self.reponseMessage);
        });
    });
    
    return self;
}


- (CHXRequest *)startRequestWithSuccess:(RequestSuccessCompletionBlock)requestSuccessCompletionBlock
                                 failue:(RequestFailureCompletionBlock)requestFailureCompletionBlock
                                 __attribute__((deprecated("use "))) {
    [self startRequest];
    
    dispatch_async(self.queue, ^{
        if (self.responseSuccess) {
            requestSuccessCompletionBlock(self.responseResult);
        } else {
            requestFailureCompletionBlock(self.reponseMessage);
        }
    });
    
    return self;
}

- (CHXRequest *)startRequestWithSuccessHandler:(RequestSuccessHandler)successHandler
                                failureHnadler:(RequestFailureHandler)failureHnadler {
    [self startRequest];
    dispatch_async(self.queue, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.responseSuccess) {
                successHandler(self, self.responseResult);
            } else {
                failureHnadler(self, self.reponseMessage);
            }
        });
    });
    
    return self;
}

@end
