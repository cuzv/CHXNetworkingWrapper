//
//  CHXRequest.h
//  CHXNetworkingWrapper
//
//  Created by Moch Xiao on 2015-04-19.
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
#import "AFNetworking.h"

// HTTP Method
typedef NS_ENUM(NSInteger, CHXRequestMethod) {
    CHXRequestMethodPost = 0,
    CHXRequestMethodGet,
    CHXRequestMethodPut,
    CHXRequestMethodDelete,
    CHXRequestMethodPatch,
    CHXRequestMethodHead
};

typedef NS_ENUM(NSInteger, CHXRequestSerializerType) {
    CHXRequestSerializerTypeHTTP = 0,
    CHXRequestSerializerTypeJSON
};

typedef NS_ENUM(NSInteger, CHXResponseSerializerType) {
    CHXResponseSerializerTypeHTTP = 0,
    CHXResponseSerializerTypeJSON,
    CHXResponseSerializerTypeImage
};

#pragma mark - Blocks

@class CHXRequest;

typedef void (^RequestSuccessCompletionBlock)(id responseObject);
typedef void (^RequestFailureCompletionBlock)(id errorMessage);
typedef void (^RequestCompletionBlock)(id responseObject, id errorMessage);
typedef void (^RequestCompletionHandle)(CHXRequest *request);
typedef void (^AFConstructingBlock)(id<AFMultipartFormData> formData);

#pragma mark - CHXRequest

// This class collection a request infos what needed, by subclass and override methods
@interface CHXRequest : NSObject
@end

#pragma mark - Subclass should overwrite thoese methods

#pragma mark - Request Construct data

@interface CHXRequest (CHXConstruct)

/**
 *  Get assembly request parameters
 *
 *  @return AF request parameters
 */
- (NSDictionary *)requestParameters;

/**
 *  Get the request URL address
 *
 *  @return URL address
 */
- (NSString *)requestURLString;

/**
 *  Get the request method
 *
 *  @return request method
 */
- (CHXRequestMethod)requestMehtod;

/**
 *  Get request paramters serialize type
 *
 *  @return request paramters serialize type
 */
- (CHXRequestSerializerType)requestSerializerType;

/**
 *  Get POST body data block
 *
 *  @return POST body data block
 */
- (AFConstructingBlock)constructingBodyBlock;

/**
 *  download file save path, the request method should always be `GET`
 *  Note: make sure the download file save path exist
 *
 *  @return download file save path
 */
- (NSString *)downloadTargetFilePathString;

/**
 *  download file progress(0~1)
 *
 *  @return progress
 */
- (void(^)(CGFloat progress))downloadProgress;

/**
 *  upload file progress(0~1)
 *  @rerturn progress
 */
- (void(^)(CGFloat progress))uploadProgress;

/**
 *  Get the request timeout setup interval
 *
 *  @return timeout interval
 */
- (NSTimeInterval)requestTimeoutInterval;

/**
 *  Get the custom URLRequest
 *  If return `nil`, ignore `requestParameters, requestBaseURLString,
 *	requestSpecificURLString, requestSuffixURLString, requestMehtod`
 *
 *	@return Custom URLRequest
 */
- (NSURLRequest *)customURLRequest;

/**
 *  Is there need cache
 *
 *  @return Default value is NO
 */
- (BOOL)requestNeedCache;

/**
 *  Get cache time interval
 *
 *  @return cache time interval, default value is 3 minutes
 */
- (NSTimeInterval)requestCacheDuration;

@end


#pragma mark - Retrieve response data

@interface CHXRequest (CHXRetrieve)

/**
 *  Get response serizlizer type, defined by API maker
 *
 *  @return response serizlizer type
 */
- (CHXResponseSerializerType)responseSerializerType;

/**
 *  Get the retrieve data api field name
 *
 *  @return retrieve data api field name
 */
- (NSString *)responseDataFieldName;

/**
 *  Get the retrieve code api field name
 *
 *  @return retrieve code api field name
 */
- (NSString *)responseCodeFieldName;

/**
 *  Get the response success code field name
 *
 *  @return success code field name
 */
- (NSInteger)responseSuccessCodeValue;

/**
 *  Get the retrieve message api field name
 *
 *  @return retrieve message api field name
 */
- (NSString *)responseMessageFieldName;

/**
 *  Convert HTTP response data to Foundation object
 *  If retrieve data using JSON, ignore this
 *  If retrieve data using form binary data, provide a method convert to Foundation object
 *
 *  @param data HTTP  respone data
 *
 *  @return Foundation object
 */
- (id)responseObjectFromRetrieveData:(id)data;

@end

#pragma mark - Perform

@interface CHXRequest (CHXPerform)

/**
 *  Start a http request
 */
- (CHXRequest *)startRequest;

/**
 *  Stop the http request
 */
- (CHXRequest *)stopRequest;

/**
 *  Notify the request is complete
 *  Only invoke by `CHXRequestProxy`
 *  No matter the request is success or not, should invoke this mehod
 */
- (CHXRequest *)notifyComplete;

@end

#pragma mark - Done asynchronously

@interface CHXRequest (CHXAsynchronously)

- (CHXRequest *)successCompletionResponse:(RequestSuccessCompletionBlock)requestSuccessCompletionBlock;
- (CHXRequest *)failureCompletionResponse:(RequestFailureCompletionBlock)requestFailureCompletionBlock;
- (CHXRequest *)completionResponse:(RequestCompletionBlock)requestCompletionBlock;
- (CHXRequest *)completionHandle:(RequestCompletionHandle)requestCompletionHandle;

@end

#pragma mark - Convenience

@interface CHXRequest (CHXConvenience)
- (CHXRequest *)startRequestWithSuccess:(RequestSuccessCompletionBlock)requestSuccessCompletionBlock failue:(RequestFailureCompletionBlock)requestFailureCompletionBlock;
@end

#pragma mark - CHXRequestProxy use

@interface CHXRequest ()

/**
 *  Hold on request task, only invoke by `CHXRequestProxy`
 */
@property (nonatomic, strong) NSURLSessionTask *requestSessionTask;

/**
 *  Retrieve data, may be nil before the request notify complete
 */
@property (nonatomic, strong) id responseObject;

/**
 *  Retrieve error message, usuall be sent NSString
 *  may be nil before the request notify complete
 */
@property (nonatomic, strong) id errorMessage;

/**
 *  Is the request response success ?
 */
@property (nonatomic, assign) BOOL responseSuccess;

/**
 *  Response code
 */
@property (nonatomic, assign) NSInteger responseCode;


@end