//
//  NWRequest.h
//  NWNetworkingWrapper
//
//  Created by Moch Xiao on 2014-12-28.
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
 *  组装请求参数
 *
 *  @return AF 请求参数
 */
- (NSDictionary *)requestParameters;

/**
 *  请求公共 URL 参数字符串
 *
 *  @return 请求 URL 参数字符串
 */
- (NSString *)requestURLString;

/**
 *  请求方式
 *
 *  @return 请求方式
 */
- (CHXRequestMethod)requestMehtod;

/**
 *  请求参数序列化类型
 *
 *  @return 序列化器类型
 */
- (CHXRequestSerializerType)requestSerializerType;

/**
 *  POST 数据提交 Block
 *
 *  @return POST 数据提交 Block
 */
- (AFConstructingBlock)constructingBodyBlock;

/**
 *  下载文件保存目录，应该设置 requestMehtod 为 GET
 *
 *  @return 文件保存目录
 */
- (NSString *)downloadTargetFilePathString;

/**
 *  请求超时时长
 *
 *  @return 请求超时时长
 */
- (NSTimeInterval)requestTimeoutInterval;

/**
 *  构建自定义的 URLRequest
 *  若这个方法返回非 nil 对象，会忽略 requestParameters, requestBaseURLString,
 *	requestSpecificURLString, requestSuffixURLString, requestMehtod 等参数
 *
 *	@return 自定义的 URLRequest
 */
- (NSURLRequest *)customURLRequest;

/**
 *  是否需要缓存
 *
 *  @return Default value is NO
 */
- (BOOL)requestNeedCache;

/**
 *  缓存时长
 *
 *  @return 缓存时长，默认3分钟
 */
- (NSTimeInterval)requestCacheDuration;

@end


#pragma mark - Retrieve response data

@interface CHXRequest (CHXRetrieve)

/**
 *  请求回送数据反序列化器类型，后台定义
 *
 *  @return 请求回送数据反序列化器类型
 */
- (CHXResponseSerializerType)responseSerializerType;

/**
 *  回送数据接口 回送主要数据 字段名称
 *
 *  @return 回送数据接口 回送主要数据 字段名称
 */
- (NSString *)responseDataFieldName;

/**
 *  回送数据接口 响应编码 字段名称，后台定义
 *
 *  @return 回送数据接口 响应编码 字段名称
 */
- (NSString *)responseCodeFieldName;

/**
 *  回送数据 成功 code，后台定义
 *
 *  @return 成功 code
 */
- (NSInteger)responseSuccessCodeValue;

/**
 *  回送数据接口 响应消息 字段名称，后台定义
 *
 *  @return 回送数据接口 响应消息 字段名称
 */
- (NSString *)responseMessageFieldName;

/// If retrieve data using JSON, ignore this
/// If retrieve data using form binary data, provide a method convert to Foundation object
/**
 *  将 HTTP 回送数据转换为 Foundation 对象
 *
 *  @param data HTTP  回送数据
 *
 *  @return Foundation 对象
 */
- (id)responseObjectFromRetrieveData:(id)data;

@end

#pragma mark - Perform

@interface CHXRequest (CHXPerform)

/**
 *  开始发起请求
 */
- (CHXRequest *)startRequest;

/**
 *  停止网络请求
 */
- (CHXRequest *)stopRequest;

/**
 *  通知请求完成，CHXRequestProxy 调用，自身或者子类不要调用，不管请求成功还是失败，这个方法一定需要调用
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
 *  持有请求任务，CHXRequestProxy 调用，自身或者子类不要调用
 */
@property (nonatomic, strong) NSURLSessionTask *requestSessionTask;

/**
 *  回送数据，请求未完成可能为空
 */
@property (nonatomic, strong) id responseObject;

/**
 *  回送错误信息，请求未完成可能为空
 */
@property (nonatomic, strong) id errorMessage;

/**
 *  是否响应成功
 */
@property (nonatomic, assign) BOOL responseSuccess;

/**
 *  响应状态码
 */
@property (nonatomic, assign) NSInteger responseCode;


@end