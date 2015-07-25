//
//  CHXRequestConstructProtocol.h
//  CHXNetworkingWrapper
//
//  Created by Moch Xiao on 7/10/15.
//  Copyright (c) 2015 Moch Xiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CHXRequestEnum.h"

@protocol AFMultipartFormData;
typedef void (^AFConstructingBlock)(id<AFMultipartFormData> formData);

@protocol CHXRequestConstructProtocol <NSObject>

@required

/// Get assembly request parameters
- (NSDictionary *)requestParameters;

/// Get the request URL address
- (NSString *)requestURLPath;

/// Get the request method
- (CHXRequestMethod)requestMethod;

/// Get request paramters serialize type
- (CHXRequestSerializerType)requestSerializerType;

@optional

/// Get POST body data block
- (AFConstructingBlock)constructingBodyBlock;

/// download file save path, the request method should always be `GET`
/// Note: make sure the download file save path exist
- (NSString *)downloadTargetFilePath;

/// download file progress(0~1)
- (void(^)(CGFloat progress))downloadProgress;

/// upload file progress(0~1)
- (void(^)(CGFloat progress))uploadProgress;

/// Get the request timeout setup interval
- (NSTimeInterval)requestTimeoutInterval;

/// Get the custom URLRequest
/// If return `nil`, ignore `requestParameters, requestBaseURLString,
/// requestSpecificURLString, requestSuffixURLString, requestMehtod`
- (NSURLRequest *)customURLRequest;

/// Get cache time interval, if 0, no need cache.
/// default value is 3 minutes
- (NSTimeInterval)requestCacheDuration;

@end
