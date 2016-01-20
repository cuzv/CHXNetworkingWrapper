//
//  CHXRequest+ResponseHandler.h
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
