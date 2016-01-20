//
//  CHXRequestConstructProtocol.h
//  CHXNetworkingWrapper
//
//  Created by Moch Xiao on 7/10/15.
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
#import "CHXRequestEnum.h"

@protocol AFMultipartFormData;
typedef void (^AFConstructingBlock)(id<AFMultipartFormData> formData);

@protocol CHXRequestConstructProtocol <NSObject>

@required

/// Get assembly request body parameters
- (NSDictionary *)requestParameters;

/// Get the request URL address
- (NSString *)requestURLPath;

/// Get the request method
- (CHXRequestMethod)requestMethod;

/// Get request paramters serialize type
- (CHXRequestSerializerType)requestSerializerType;

@optional

/// Get assembly request header parameters
- (NSDictionary *)requestHeaderParameters;

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
