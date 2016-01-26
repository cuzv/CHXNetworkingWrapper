//
//  CHXRequestable.h
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

#import <UIKit/UIKit.h>
#import "CHXNetworkingWrapperDefine.h"
#import "CHXCommandability.h"

@protocol AFMultipartFormData;
typedef void (^AFConstructingBlock)(id<AFMultipartFormData> __nonnull formData);

@protocol CHXRequestable <NSObject>

@required

/// The request command. Returned value must conform `CHXCommandability`,
/// default implemnt provide `CHXAFCommand`.
- (nonnull id)requestCommand;

/// The request url string.
- (nonnull NSString *)requestURLPath;

@optional

/// The request method
- (CHXRequestMethod)requestMethod;

/// The request body parameters.
- (nonnull NSDictionary<NSString *, id> *)requestBodyParameters;

/// The request header parameters.
- (nonnull NSDictionary<NSString *, NSString *> *)requestHeaderParameters;

/// The request parameter encoding.
- (CHXParameterEncoding)requestParameterEncoding;

/// The request timeout interval, `10` by default.
- (NSTimeInterval)requestTimeoutInterval;

/// The POST body data block
- (nonnull AFConstructingBlock)constructingBodyBlock;


/// Download file save path, the request method should always be `GET`.
/// **Note**: make sure the download file save path exist.
- (nonnull NSString *)downloadTargetFilePath;

/// download file progress(0~1)
- (nonnull void(^)(CGFloat progress))downloadProgress;

/// upload file progress(0~1)
- (nonnull void(^)(CGFloat progress))uploadProgress;


/// The custom URLRequest
/// If return `nil`, ignore `requestParameters, requestBaseURLString,
/// requestSpecificURLString, requestSuffixURLString, requestMehtod`
- (nonnull NSURLRequest *)customURLRequest;

@end
