//
//  CHXRequest+ResponseHandler.h
//  CHXNetworkingWrapper
//
//  Created by Moch Xiao on 7/11/15.
//  Copyright (c) 2015 Moch Xiao. All rights reserved.
//

#import "CHXRequest.h"

/// Deprecated
typedef void (^RequestSuccessCompletionBlock)(id responseObject) __attribute__((deprecated("use RequestSuccessHandler: instead")));
typedef void (^RequestFailureCompletionBlock)(id errorMessage) __attribute__((deprecated("use RequestFailureHandler: instead")));
typedef void (^RequestCompletionBlock)(id responseObject, id errorMessage) __attribute__((deprecated("use RequestCompletionHandler: instead")));

/// Preferred
typedef void (^RequestCompletionHandler)(CHXRequest *request, id responseObject);
typedef void (^RequestSuccessHandler)(CHXRequest *request, id responseResult);
typedef void (^RequestFailureHandler)(CHXRequest *request, id responseMessage);

@interface CHXRequest (ResponseHandler)

/// Deprecated: deliver on backend thread
- (CHXRequest *)successCompletionResponse:(RequestSuccessCompletionBlock)requestSuccessCompletionBlock
                __attribute__((deprecated("use successHandler: instead")));
- (CHXRequest *)completionResponse:(RequestCompletionBlock)requestCompletionBlock
                __attribute__((deprecated("use completionHandler: instead")));
- (CHXRequest *)failureCompletionResponse:(RequestFailureCompletionBlock)requestFailureCompletionBlock
                __attribute__((deprecated("use failureHnadler: instead")));

/// Preferred: deliver on main thread
- (CHXRequest *)completionHandler:(RequestCompletionHandler)completionHandler;
- (CHXRequest *)successHandler:(RequestSuccessHandler)successHandler;
- (CHXRequest *)failureHnadler:(RequestFailureHandler)failureHnadler;

/// Deprecated: deliver on backend thread
- (CHXRequest *)startRequestWithSuccess:(RequestSuccessCompletionBlock)requestSuccessCompletionBlock
                                 failure:(RequestFailureCompletionBlock)requestFailureCompletionBlock
                                 __attribute__((deprecated("use startRequestWithSuccessHandler:failureHandler instead")));

/// Preferred: deliver on main thread
- (CHXRequest *)startRequestWithSuccessHandler:(RequestSuccessHandler)successHandler
                                failureHandler:(RequestFailureHandler)failureHandler;

@end
