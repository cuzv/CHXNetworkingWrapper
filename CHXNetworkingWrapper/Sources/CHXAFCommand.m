//
//  CHXRequestAFCommand.m
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

#import "CHXAFCommand.h"
#import "AFHTTPSessionManager.h"
#import "CHXRequest.h"
#import "CHXRequest+Internal.h"
#import "CHXResponseable.h"
#import "CHXRequestable.h"
#import "CHXErrorCodeDescription.h"

@interface CHXAFCommand ()
@property (nonatomic, weak) CHXRequest *request;
@property (nonatomic, weak) id<CHXRequestable, CHXResponseable> setup;
@property (nonatomic, weak) AFHTTPSessionManager *sessionManager;
@property (nonatomic, strong) NSURLSessionTask *task;
@end

NSString * const CHXNetworkingReachabilityDidChangeNotification = @"CHXNetworkingReachabilityDidChangeNotification";
NSString * const CHXNetworkingReachabilityNotificationStatusItem = @"CHXNetworkingReachabilityNotificationStatusItem";

NSString * const CHXNetworkReachabilityStatusUnknown = @"CHXNetworkReachabilityStatusUnknown";
NSString * const CHXNetworkReachabilityStatusNotReachable = @"CHXNetworkReachabilityStatusNotReachable";
NSString * const CHXNetworkReachabilityStatusReachableViaWWAN = @"CHXNetworkReachabilityStatusReachableViaWWAN";
NSString * const CHXNetworkReachabilityStatusReachableViaWiFi = @"CHXNetworkReachabilityStatusReachableViaWiFi";

static BOOL __firstTimeRunToHere = YES;

@implementation CHXAFCommand

#if DEBUG
- (void)dealloc {
    NSLog(@"~~~~~~~~~~~%s~~~~~~~~~~~", __FUNCTION__);
}
#endif

static AFHTTPSessionManager *__sessionManager;
- (AFHTTPSessionManager *)sessionManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __sessionManager = [AFHTTPSessionManager manager];
        __sessionManager.operationQueue.maxConcurrentOperationCount = 4;
        [__sessionManager.reachabilityManager startMonitoring];
        [__sessionManager.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            status = status + 1;
            NSDictionary *userInfo = @{CHXNetworkingReachabilityNotificationStatusItem: _reachabilityStatus()[status]};
            [[NSNotificationCenter defaultCenter] postNotificationName:CHXNetworkingReachabilityDidChangeNotification object:nil userInfo:userInfo];            
        }];
    });
    
    return __sessionManager;
}

static NSArray *__status;
NSArray *_reachabilityStatus() {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __status = @[CHXNetworkReachabilityStatusUnknown,
                     CHXNetworkReachabilityStatusNotReachable,
                     CHXNetworkReachabilityStatusReachableViaWWAN,
                     CHXNetworkReachabilityStatusReachableViaWiFi];
    });
    return __status;
}

#pragma mark - CHXCommandability

- (void)injectRequest:(nonnull CHXRequest *)request {
    self.request = request;
    self.setup = request.setup;
    [self _processRequest];
}

- (void)_processRequest {
    if (![self _isNetworkReachable]) {
        if (__firstTimeRunToHere) {
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                __firstTimeRunToHere = NO;
            });
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
               [self injectRequest:self.request];
            });
        }
        
        return;
    }
    
    NSURLRequest *customURLRequest = [self _customURLRequest];
    if (customURLRequest) {
        AFURLSessionManager *manager = [AFURLSessionManager new];
        __weak typeof(self) weak_self = self;
        self.task = [manager dataTaskWithRequest:customURLRequest completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
            __strong typeof(weak_self) strong_self = weak_self;
            if (error) {
                [self _handleFailure:strong_self.task error:error];
            } else {
                [self _handleSuccess:strong_self.task responseObject:responseObject];
            }
        }];
        return;
    }
    
    // HTTP Method
    CHXRequestMethod method = [self _requestMethod];
    // HTTP API absolute URL
    NSString *URLPath = [self.setup requestURLPath];
    // HTTP POST value block
    AFConstructingBlock constructingBodyBlock = [self _constructingBodyBlock];
    // SerializerType
    [self _setupRequestSerializer];
    [self _setupResponseSerializer];
    // Headers
    [self _setupHeader];
    NSDictionary *parameters = [self _bodyParameters];
    // Completion handler
    void (^successHandler)(NSURLSessionTask *task, id _Nullable responseObject) = ^(NSURLSessionTask *task, id _Nullable responseObject) {
        [self _handleSuccess:task responseObject:responseObject];
    };
    void (^failureHandler)(NSURLSessionTask * _Nullable task, NSError *error) = ^(NSURLSessionTask * _Nullable task, NSError *error) {
        [self _handleFailure:task error:error];
    };

    if (self.request.printDebugInfo) {
        NSLog(@"URLPath: %@", URLPath);
        NSLog(@"Parameters: %@", parameters);
    }
    
    if (CHXRequestMethodGet == method) {
        void(^progress)(NSProgress *) = [self _downloadProgress];
        NSString *downloadTargetFilePath = [self _downloadTargetFilePath];
        if (downloadTargetFilePath) {
            // fileRemoteURL
            NSURLRequest *downURLRequest = [self _requestFileRemoteURLRequest];
            __weak typeof(self) weak_self = self;
            AFURLSessionManager *sessionManager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
            self.task = [sessionManager downloadTaskWithRequest:downURLRequest progress:progress destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
                return [NSURL URLWithString:downloadTargetFilePath];
            } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
                __strong typeof(weak_self) strong_self = weak_self;
                if (error) {
                    failureHandler(strong_self.task, error);
                } else {
                    successHandler(strong_self.task, [self _buildSuccessInfoForResponseObject:@{}]);
                }
            }];
            [self.task resume];
        }
        else {
            self.task = [self.sessionManager GET:URLPath parameters:parameters progress:progress success:successHandler failure:failureHandler];
        }
    }
    else if (CHXRequestMethodPost == method) {
        void(^progress)(NSProgress *progress) = [self _uploadProgress];
        self.task = [self.sessionManager POST:URLPath parameters:parameters constructingBodyWithBlock:constructingBodyBlock progress:progress success:successHandler failure:failureHandler];
    }
    else if (CHXRequestMethodPut == method) {
        self.task = [self.sessionManager PUT:URLPath parameters:parameters success:successHandler failure:failureHandler];
    }
    else if (CHXRequestMethodDelete == method) {
        self.task = [self.sessionManager DELETE:URLPath parameters:parameters success:successHandler failure:failureHandler];
    }
    else if (CHXRequestMethodPatch == method) {
        self.task = [self.sessionManager PATCH:URLPath parameters:parameters success:successHandler failure:failureHandler];
    }
    else if (CHXRequestMethodHead == method) {
        self.task = [self.sessionManager HEAD:URLPath parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task) {
            successHandler(task, nil);
        } failure:failureHandler];
    }
}

- (BOOL)_isNetworkReachable {
    return [self.sessionManager.reachabilityManager isReachable];
}

- (nullable NSURLRequest *)_customURLRequest {
    return [self.setup respondsToSelector:@selector(customURLRequest)] ? [self.setup customURLRequest] : nil;
}

- (CHXRequestMethod)_requestMethod {
    return [self.setup respondsToSelector:@selector(requestMethod)] ? [self.setup requestMethod] : CHXRequestMethodGet;
}

- (nullable AFConstructingBlock)_constructingBodyBlock {
    return [self.setup respondsToSelector:@selector(constructingBodyBlock)] ? [self.setup constructingBodyBlock] : nil;
}

- (void)_setupRequestSerializer {
    CHXParameterEncoding encoding = [self _requestParameterEncoding];
    switch (encoding) {
        case CHXParameterEncodingJSON:
            self.sessionManager.requestSerializer = _JSONRequestSerializer();
            break;
        case CHXParameterEncodingPropertyList:
            self.sessionManager.requestSerializer = _PropertyListRequestSerializer();
            break;
        default:
            self.sessionManager.requestSerializer = _HTTPRequestSerializer();
            break;
    }
    
    self.sessionManager.requestSerializer.timeoutInterval = [self _requestTimeoutInterval];
}

static AFJSONRequestSerializer *__JSONRequestSerializer;
AFJSONRequestSerializer *_JSONRequestSerializer() {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __JSONRequestSerializer = [AFJSONRequestSerializer serializer];
    });
    return __JSONRequestSerializer;
}

static AFPropertyListRequestSerializer *__PropertyListRequestSerializer;
AFPropertyListRequestSerializer *_PropertyListRequestSerializer() {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __PropertyListRequestSerializer = [AFPropertyListRequestSerializer serializer];
    });
    return __PropertyListRequestSerializer;
}

static AFHTTPRequestSerializer *__HTTPRequestSerializer;
AFHTTPRequestSerializer *_HTTPRequestSerializer() {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __HTTPRequestSerializer = [AFHTTPRequestSerializer serializer];
    });
    return __HTTPRequestSerializer;
}

- (CHXParameterEncoding)_requestParameterEncoding {
    return [self.setup respondsToSelector:@selector(requestParameterEncoding)] ? [self.setup requestParameterEncoding] : CHXParameterEncodingURL;
}

- (NSTimeInterval)_requestTimeoutInterval {
    return [self.setup respondsToSelector:@selector(requestTimeoutInterval)] ? [self.setup requestTimeoutInterval] : 10.0f;
}

- (void)_setupResponseSerializer {
    CHXResponseEncoding encoding = [self _responseEncoding];
    switch (encoding) {
        case CHXResponseEncodingJSON:
            self.sessionManager.responseSerializer = _JSONResponseSerializer();
            break;
        case CHXResponseEncodingImage:
            self.sessionManager.responseSerializer = _ImageResponseSerializer();
            break;
        default:
            self.sessionManager.responseSerializer = _HTTPResponseSerializer();
            break;
    }
}

static AFJSONResponseSerializer *__JSONResponseSerializer;
AFJSONResponseSerializer *_JSONResponseSerializer() {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __JSONResponseSerializer = [AFJSONResponseSerializer serializer];
    });
    return __JSONResponseSerializer;
}

static AFImageResponseSerializer *__ImageResponseSerializer;
AFImageResponseSerializer *_ImageResponseSerializer() {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __ImageResponseSerializer = [AFImageResponseSerializer serializer];
    });
    return __ImageResponseSerializer;
}

static AFHTTPResponseSerializer *__HTTPResponseSerializer;
AFHTTPResponseSerializer *_HTTPResponseSerializer() {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __HTTPResponseSerializer = [AFHTTPResponseSerializer serializer];
    });
    return __HTTPResponseSerializer;
}

- (CHXResponseEncoding)_responseEncoding {
    return [self.setup respondsToSelector:@selector(responseEncoding)] ? [self.setup responseEncoding] : CHXResponseEncodingForm;
}

- (nullable NSDictionary *)_headerParameters {
    return [self.setup respondsToSelector:@selector(requestHeaderParameters)] ? [self.setup requestHeaderParameters] : nil;
}

- (void)_setupHeader {
    NSDictionary *header = [self _headerParameters];
    if (!header) {
        return;
    }

    // Clear headers.
    // Hack mutableHTTPRequestHeaders.
    [self.sessionManager.requestSerializer setValue:[NSMutableDictionary dictionary] forKey:@"mutableHTTPRequestHeaders"];
    
    // Reset new headers.
    [header enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [self.sessionManager.requestSerializer setValue:obj forHTTPHeaderField:key];
    }];
    
    if (self.request.printDebugInfo) {
        NSLog(@"header: %@", header);
    }
}

- (NSDictionary *)_bodyParameters {
    return [self.setup respondsToSelector:@selector(requestBodyParameters)] ? [self.setup requestBodyParameters] : @{};
}

- (nullable void(^)(NSProgress *progress))_downloadProgress {
    if (![self.setup respondsToSelector:@selector(downloadProgress)]) {
        return nil;
    }
    
    void(^downloadProgress)(CGFloat progress) = [self.setup downloadProgress];
    void(^progress)(NSProgress *) = ^(NSProgress *progress) {
        downloadProgress(progress.completedUnitCount *1.0f / progress.totalUnitCount * 1.0f);
    };

    return progress;
}

- (nullable NSString *)_downloadTargetFilePath {
    NSString *filePath = [self.setup respondsToSelector:@selector(downloadTargetFilePath)] ? [self.setup downloadTargetFilePath] : nil;
    
    if (filePath && ![filePath hasPrefix:@"file://"]) {
        filePath = [@"file://" stringByAppendingString:filePath];
    }

    return filePath;
}

- (nullable void(^)(NSProgress *progress))_uploadProgress {
    if (![self.setup respondsToSelector:@selector(uploadProgress)]) {
        return nil;
    }
    
    void(^uploadProgress)(CGFloat progress) = [self.setup uploadProgress];
    void(^progress)(NSProgress *) = ^(NSProgress *progress) {
        uploadProgress(progress.completedUnitCount *1.0f / progress.totalUnitCount * 1.0f);
    };

    return progress;
}

- (NSString *)_requestFileRemoteURLPath {
    NSString *originalURLString = [self.setup requestURLPath];
    NSString *parametersURLString = [self _buildParameters];
    NSString *resultURLString = [NSString stringWithString:originalURLString];
    
    if (parametersURLString && parametersURLString.length) {
        if ([originalURLString rangeOfString:@"?"].location != NSNotFound) {
            resultURLString = [resultURLString stringByAppendingString:parametersURLString];
        } else {
            resultURLString = [resultURLString stringByAppendingFormat:@"?%@", [parametersURLString substringFromIndex:1]];
        }
        return resultURLString;
    } else {
        return originalURLString;
    }
}

- (NSURLRequest *)_requestFileRemoteURLRequest {
    NSURL *fileRemoteURL = [NSURL URLWithString:[self _requestFileRemoteURLPath]];
    return [NSURLRequest requestWithURL:fileRemoteURL];
}

- (NSString *)_buildParameters {
    NSDictionary *parameters = [self _bodyParameters];
    
    NSMutableString *parametersURLString = [@"" mutableCopy];
    if (parameters && parameters.count) {
        for (NSString *key in parameters) {
            NSString *value = parameters[key];
            value = [NSString stringWithFormat:@"%@", value];
            value = [self _URLEncode:value];
            [parametersURLString appendFormat:@"&%@=%@", key, value];
        }
    }
    
    return [NSString stringWithString:parametersURLString];
}

- (NSString *)_URLEncode:(NSString *)string {
    // See: https://github.com/AFNetworking/AFNetworking/pull/555
    NSString *result = (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                             (__bridge CFStringRef)string,
                                                                                             CFSTR("."),
                                                                                             CFSTR(":/?#[]@!$&'()*+,;="),
                                                                                             kCFStringEncodingUTF8);
    return result;
}

- (NSDictionary *)_buildSuccessInfoForResponseObject:(nonnull id)responseObject {
    NSString *responseCodeFieldName = [self.setup responseCodeFieldName];
    NSInteger responseSuccessCodeValue = [self.setup responseSuccessCodeValue];
    NSString *responseResultFieldName = [self.setup responseResultFieldName];

    return @{responseCodeFieldName:@(responseSuccessCodeValue),
             responseResultFieldName:responseObject};
}

- (void)_handleSuccess:(NSURLSessionTask *)task responseObject:(nullable id)responseObject {
    if (!responseObject) {
        if (CHXRequestMethodHead != [self _requestMethod]) {
            NSString *message = @"服务器未返回数据。";
            [self _handleFailure:task error:[NSError errorWithDomain:@"com.foobar.ServerError" code:HUGE_VAL userInfo:@{NSLocalizedFailureReasonErrorKey:message, NSLocalizedDescriptionKey:message}]];
        }
        return;
    }

    ConvertResponseHandler handler = [self _convertResponseHandler];
    if (handler) {
        responseObject = handler(responseObject);
    }
    if (self.request.printDebugInfo) {
        NSLog(@"responseObject: %@", responseObject);
    }
    
    self.request.responseObject = responseObject;
    
    NSString *responseCodeFieldName = [self.setup responseCodeFieldName];
    NSString *responseMessageFieldName = [self.setup responseMessageFieldName];
    if (!responseObject) {
        responseObject = @{responseCodeFieldName:@(HUGE_VAL),
                           responseMessageFieldName:NSLocalizedString(@"服务器返回数据无法处理，请稍后再试。", nil)};
    }

    NSInteger responseCode = [[responseObject objectForKey:responseCodeFieldName] integerValue];
    self.request.responseCode = responseCode;
    NSInteger responseSuccessCodeValue = [self.setup responseSuccessCodeValue];
    if (responseCode == responseSuccessCodeValue) {
        // Setup response result field value
        NSString *responseResultFieldName = [self.setup responseResultFieldName];
        id responseResult = [responseObject objectForKey:responseResultFieldName];
        self.request.responseResult = responseResult;
        
        // Setup response status
        self.request.responseSuccess = YES;
    } else {
        // Setup response message field value
        id responseMessage = [responseObject objectForKey:responseMessageFieldName];
        self.request.responseMessage = responseMessage;
    }
    
    [self.request notifyComplete];
}

- (nullable ConvertResponseHandler)_convertResponseHandler {
    return [self.setup respondsToSelector:@selector(convertResponseHandler)] ? [self.setup convertResponseHandler] : nil;
}

- (void)_handleFailure:(nullable NSURLSessionTask *)task error:(NSError *)error {
    if (self.request.printDebugInfo) {
        NSLog(@"Error: %@", CHXStringFromCFNetworkErrorCode(error.code));
    }
    
    self.request.responseMessage = error.userInfo[NSLocalizedDescriptionKey];
    self.request.responseCode = error.code;

    [self.request notifyComplete];
}

#pragma mark -

- (void)removeRequest {
    [self.task cancel];
    self.task = nil;
}

@end
