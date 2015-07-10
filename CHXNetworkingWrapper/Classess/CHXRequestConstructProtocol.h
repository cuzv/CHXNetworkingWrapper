//
//  CHXRequestConstructProtocol.h
//  CHXNetworkingWrapper
//
//  Created by Moch Xiao on 7/10/15.
//  Copyright (c) 2015 Moch Xiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CHXRequestEnum.h"

typedef void (^AFConstructingBlock)(id<AFMultipartFormData> formData);

@protocol CHXRequestConstructProtocol <NSObject>

@required

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
- (NSString *)requestURLPath;

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

@optional

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
- (NSString *)downloadTargetFilePath;

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
 *  Get cache time interval, if 0, no need cache
 *
 *  @return cache time interval, default value is 3 minutes
 */
- (NSTimeInterval)requestCacheDuration;

@end
