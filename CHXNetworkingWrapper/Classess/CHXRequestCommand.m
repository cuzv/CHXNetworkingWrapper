//
//  CHXRequestCommand.m
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

#import "CHXRequestCommand.h"
#import "AFNetworking.h"
#import "CHXMacro.h"
#import "CHXRequest.h"
#import "CHXResponseCache.h"
#import "CHXErrorCodeDescription.h"
#import "NSObject+ObjcRuntime.h"
#import "CHXRequest+CHXRequestCommand.h"
#import "CHXRequest+Private.h"

#pragma mark -

@interface CHXRequestCommand ()
@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;
@property (nonatomic, strong) NSMutableDictionary *dataTaskContainer;
@property (nonatomic, copy) void (^networkReachabilityStatusChangeBlock)(AFNetworkReachabilityStatus status);
@property (nonatomic, copy) void (^completionHandler)(void);
@end

@implementation CHXRequestCommand

+ (instancetype)sharedInstance {
    static CHXRequestCommand *_sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [self new];
    });
    
    return _sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _networkNotReachableDescription = @"当前网络无连接，请稍候再试！";
    _debugMode = YES;
    
    _sessionManager = [AFHTTPSessionManager manager];
    _sessionManager.operationQueue.maxConcurrentOperationCount = 4;
    [_sessionManager.reachabilityManager startMonitoring];
    
    _dataTaskContainer = [NSMutableDictionary new];

    // Monitor networking status
    __weak typeof(self) weakSelf = self;
    [_sessionManager.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf.networkReachabilityStatusChangeBlock) {
            strongSelf.networkReachabilityStatusChangeBlock(status);
        }
        if (strongSelf.debugMode) {
            NSLog(@"AFNetworkReachabilityStatus: %@", AFStringFromNetworkReachabilityStatus(status));
        }
    }];
    
    // When background download file complete, but move to target path failure, will post this notification
    [[NSNotificationCenter defaultCenter] addObserverForName:AFURLSessionDownloadTaskDidFailToMoveFileNotification object:nil queue:[NSOperationQueue currentQueue] usingBlock:^(NSNotification *note) {
        if (_debugMode) {
            NSLog(@"AFURLSessionDownloadTaskDidFailToMoveFileNotification: %@", note);
        }
    }];
    
    return self;
}

- (NSUInteger)maxConcurrentOperationCount {
    return self.sessionManager.operationQueue.maxConcurrentOperationCount;
}

- (void)setMaxConcurrentOperationCount:(NSUInteger)maxConcurrentOperationCount {
    _sessionManager.operationQueue.maxConcurrentOperationCount = maxConcurrentOperationCount;
}

- (void)setReachabilityStatusChangeBlock:(void (^)(AFNetworkReachabilityStatus status))block {
    self.networkReachabilityStatusChangeBlock = block;
}

#pragma mark - CHXRequestCommandProtocol

- (void)addRequest:(CHXRequest *)request {
    // Checking Networking status
    if (![self pr_isNetworkReachable]) {

        // If cache exist, return cache data
        if (![self pr_shouldContinueRequest:request]) {
            return;
        }
        // `AFNetworkReachabilityManager` first request network status is always `AFNetworkReachabilityStatusUnknown`
        //  So, retry after 1s.
        if (request && request.currentRetryCount < 3) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self addRequest:request];
            });
            request.currentRetryCount += 1;
            return;
        }
        
        // The first time description is not correct !
        if ([CHXRequestCommand sharedInstance].debugMode) {
            NSLog(@"The network is currently unreachable.");
        }
        request.responseMessage = self.networkNotReachableDescription;
        
        // Notify request complete
        [request notifyComplete];
        
        return;
    }
    
    // Start request
    NSURLSessionTask *dataTask = nil;
    NSDictionary *requestParameters = nil;
    
    // Completion handler
    void (^successHandler)(NSURLSessionDataTask *task, id responseObject) = ^(NSURLSessionDataTask *task, id responseObject) {
        [self pr_handleRequestSuccessWithSessionDataTask:task responseObject:responseObject];
    };
    void (^failureHandler)(NSURLSessionDataTask *task, NSError *error) = ^(NSURLSessionDataTask *task, NSError *error) {
        [self pr_handleRequestFailureWithSessionDataTask:task error:error];
    };
    
    NSURLRequest *customRULRequest = [request.subclass respondsToSelector:@selector(customURLRequest)] ? [request.subclass customURLRequest] : nil;
    if (customRULRequest) {
        NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        AFURLSessionManager *sessionManager = [[AFURLSessionManager alloc] initWithSessionConfiguration:sessionConfiguration];
        dataTask = [sessionManager dataTaskWithRequest:customRULRequest completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
            if (error) {
                successHandler((NSURLSessionDataTask *)dataTask, responseObject);
            } else {
                successHandler((NSURLSessionDataTask *)dataTask, responseObject);
            }
        }];
        [dataTask resume];
        
        // Open networking activity indicator
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    } else {
        // If cache exist, return cache data
        if (![self pr_shouldContinueRequest:request]) {
            return;
        }
        
        // HTTP Method
        CHXRequestMethod requestMethod = [request.subclass requestMethod];
        NSAssert(requestMethod <= CHXRequestMethodHead, @"Unsupport Request Method");
        NSAssert(requestMethod >= CHXRequestMethodPost, @"Unsupport Request Method");
        
        // HTTP API absolute URL
        NSString *requestAbsoluteURLString = [request.subclass requestURLPath];
        NSParameterAssert(requestAbsoluteURLString);
        NSParameterAssert(requestAbsoluteURLString.length);
        
        // HTTP POST value block
        
        AFConstructingBlock constructingBodyBlock = [request.subclass respondsToSelector:@selector(constructingBodyBlock)] ? [request.subclass constructingBodyBlock] : nil;
        
        // SerializerType
        [self pr_settingupRequestSerializerTypeByRequest:request];
        [self pr_settingupResponseSerializerTypeByRequest:request];
        
        // HTTP Request parameters
        requestParameters = [request.subclass requestParameters];
        NSParameterAssert(requestParameters);

        // Open networking activity indicator
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
        switch (requestMethod) {
            case CHXRequestMethodPost: {
                if (constructingBodyBlock) {
                    dataTask = [self.sessionManager POST:requestAbsoluteURLString parameters:requestParameters constructingBodyWithBlock:constructingBodyBlock success:successHandler failure:failureHandler];
                    
                    // Setup upload progress
                    void(^block)(CGFloat progress) = [request.subclass respondsToSelector:@selector(uploadProgress)] ? [request.subclass uploadProgress] : nil;
                    if (!block) {
                        return;
                    }
                    [self.sessionManager setTaskDidSendBodyDataBlock:^(NSURLSession *session, NSURLSessionTask *task, int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
                        block(totalBytesSent * 1.0f / totalBytesExpectedToSend * 1.0f);
                    }];
                    __weak typeof(self.sessionManager) weakSessionManager = self.sessionManager;
                    [self.sessionManager setTaskDidCompleteBlock:^(NSURLSession *session, NSURLSessionTask *task, NSError *error) {
                        __strong typeof(weakSessionManager) strongSessionManager = weakSessionManager;
                        [strongSessionManager setTaskDidSendBodyDataBlock:^(NSURLSession *session, NSURLSessionTask *task, int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
                            // Do nothing
                        }];
                    }];                    
                } else {
                    dataTask = [self.sessionManager POST:requestAbsoluteURLString parameters:requestParameters success:successHandler failure:failureHandler];
                }
            }
                break;
            case CHXRequestMethodGet: {
                NSString *downloadTargetFilePath = [request.subclass respondsToSelector:@selector(downloadTargetFilePath)]? [request.subclass downloadTargetFilePath] : nil;
                if (![downloadTargetFilePath hasPrefix:@"file://"]) {
                    downloadTargetFilePath = [@"file://" stringByAppendingString:downloadTargetFilePath];
                }
                if (downloadTargetFilePath) {
                    NSParameterAssert(downloadTargetFilePath.length);
                    
                    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
                    AFURLSessionManager *sessionManager = [[AFURLSessionManager alloc] initWithSessionConfiguration:sessionConfiguration];
                    // fileRemoteURL
                    NSString *fileRemoteURLString = [self pr_requestFileRemoteURLStringWithRequest:request];
                    NSURL *fileRemoteURL = [NSURL URLWithString:fileRemoteURLString];
                    NSURLRequest *downURLRequest = [NSURLRequest requestWithURL:fileRemoteURL];

                    dataTask = [sessionManager downloadTaskWithRequest:downURLRequest progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
                        return [NSURL URLWithString:downloadTargetFilePath];
                    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
                        if (error) {
                            failureHandler((NSURLSessionDataTask *)request.requestSessionTask, error);
                        } else {
                            id object = [self pr_buildResponseObject:filePath forRequest:request];
                            successHandler((NSURLSessionDataTask *)request.requestSessionTask, object);
                        }
                    }];

                    // Setup progress callback
                    void(^block)(CGFloat progress) = [request.subclass respondsToSelector:@selector(downloadProgress)] ? [request.subclass downloadProgress] : nil;
                    if (block) {
                        [sessionManager setDownloadTaskDidWriteDataBlock:^(NSURLSession *session, NSURLSessionDownloadTask *downloadTask, int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
                                block(totalBytesWritten * 1.0f / totalBytesExpectedToWrite * 1.0f);
                        }];
                    }
                    
                    // If download on background
                    [sessionManager setDownloadTaskDidFinishDownloadingBlock:^NSURL *(NSURLSession *session, NSURLSessionDownloadTask *downloadTask, NSURL *location) {
                        return [NSURL URLWithString:downloadTargetFilePath];
                    }];
                    [dataTask resume];
                } else {
                    dataTask = [self.sessionManager GET:requestAbsoluteURLString parameters:requestParameters success:successHandler failure:failureHandler];
                }
            }
                break;
            case CHXRequestMethodPut: {
                dataTask = [self.sessionManager PUT:requestAbsoluteURLString parameters:requestParameters success:successHandler failure:failureHandler];
            }
                break;
            case CHXRequestMethodDelete: {
                dataTask = [self.sessionManager DELETE:requestAbsoluteURLString parameters:requestParameters success:successHandler failure:failureHandler];
            }
                break;
            case CHXRequestMethodPatch: {
                dataTask = [self.sessionManager PATCH:requestAbsoluteURLString parameters:requestParameters success:successHandler failure:failureHandler];
            }
                break;
            case CHXRequestMethodHead: {
                dataTask = [self.sessionManager HEAD:requestAbsoluteURLString parameters:requestAbsoluteURLString success:^(NSURLSessionDataTask *task) {
                    successHandler(task, nil);
                } failure:failureHandler];
            }
                break;
            default:
                break;
        }
    }
    
    // Connect Request and Data task
    request.requestSessionTask = dataTask;
    
    // Record the request task
    self.dataTaskContainer[@(dataTask.taskIdentifier)] = request;
    
    // For debug
    if (self.debugMode) {
        NSLog(@"Request URL: %@", dataTask.currentRequest.URL);
        NSLog(@"Request parameters: %@", requestParameters);
    }
}

- (void)removeRequest:(CHXRequest *)request {
    [request.requestSessionTask cancel];
    [self pr_prepareDeallocRequest:request];
}

- (void)removeAllRequest {
    [_sessionManager.operationQueue cancelAllOperations];
    
    __weak typeof(self) weakSelf = self;
    [self.dataTaskContainer enumerateKeysAndObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id key, id obj, BOOL *stop) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if ([obj isKindOfClass:[CHXRequest class]]) {
            CHXRequest *request = (CHXRequest *)obj;
            [strongSelf removeRequest:request];
        }
    }];
}

#pragma mark - Private

- (BOOL)pr_isNetworkReachable {
    return [self.sessionManager.reachabilityManager isReachable];
}

- (BOOL)pr_shouldContinueRequest:(CHXRequest *)request {
    // If Need cache means may be data already cached
    NSTimeInterval cacheTimeInterval = [request.subclass respondsToSelector:@selector(requestCacheDuration)] ? [request.subclass requestCacheDuration] : 0.0f;
    if (cacheTimeInterval <= 0) {
        return YES;
    }
    
    // If cache data not exist, should continure request
    CHXResponseCache *cacheResponse = [self pr_cacheForRequest:request];
    if (!cacheResponse.cahceResponseObject || !cacheResponse.cacheDate) {
        return YES;
    }
    
    NSTimeInterval interval = -[cacheResponse.cacheDate timeIntervalSinceNow];
    if (interval > cacheTimeInterval) {
        return YES;
    }
    // handle request success
    [self pr_handleRequestSuccessWithRequest:request responseObject:cacheResponse.cahceResponseObject];
    
    // dealloc request
    [self pr_prepareDeallocRequest:request];
    
    if (self.debugMode) {
        NSLog(@"Retrieve data from cache.");
    }
    
    return NO;
}

- (CHXResponseCache *)pr_cacheForRequest:(CHXRequest *)request {
    // Retrieve cache data
    NSString *filePath = [self pr_cacheFilePathStringForReqeust:request];
    CHXResponseCache *cache = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
    
    return cache;
}

- (void)pr_cacheIfNeededWithRequest:(CHXRequest *)request responseObject:(id)responseObject {
    NSTimeInterval cacheTimeInterval = [request.subclass respondsToSelector:@selector(requestCacheDuration)] ? [request.subclass requestCacheDuration] : 0.0f;
    if (cacheTimeInterval <= 0) {
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Cache file path
        NSString *filePath = [self pr_cacheFilePathStringForReqeust:request];
        
        // Cache data
        CHXResponseCache *cache = [CHXResponseCache new];
        cache.cacheDate = [NSDate date];
        cache.cahceResponseObject = responseObject;
        [NSKeyedArchiver archiveRootObject:cache toFile:filePath];
    });
}

- (NSString *)pr_cacheFilePathStringForReqeust:(CHXRequest *)request {
    NSString *fileName = nil;
    if ([request objc_properties].count) {
        fileName = [NSString stringWithFormat:@"%zd", [request hash]];
    } else {
        fileName = NSStringFromClass([request class]);
    }
    
    NSString *filePath = [NSTemporaryDirectory() stringByAppendingString:fileName];
    return filePath;
}

- (NSString *)pr_requestFileRemoteURLStringWithRequest:(CHXRequest *)request {
    NSString *originalURLString = [request.subclass requestURLPath];
    NSString *parametersURLString = [self pr_buildParametersToURLStringWithRequest:request];
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

- (NSString *)pr_buildParametersToURLStringWithRequest:(CHXRequest *)request {
    NSDictionary *parameters = [request.subclass requestParameters];
    
    NSMutableString *parametersURLString = [@"" mutableCopy];
    if (parameters && parameters.count) {
        for (NSString *key in parameters) {
            NSString *value = parameters[key];
            value = [NSString stringWithFormat:@"%@", value];
            value = [self pr_URLEncode:value];
            [parametersURLString appendFormat:@"&%@=%@", key, value];
        }
    }
    
    return [NSString stringWithString:parametersURLString];
}


- (NSString *)pr_URLEncode:(NSString *)string {
    // https://github.com/AFNetworking/AFNetworking/pull/555
    NSString *result = (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                             (__bridge CFStringRef)string,
                                                                                             CFSTR("."),
                                                                                             CFSTR(":/?#[]@!$&'()*+,;="),
                                                                                             kCFStringEncodingUTF8);
    return result;
}

- (void)pr_settingupRequestSerializerTypeByRequest:(CHXRequest *)request {
    CHXRequestSerializerType requestSerializerType = [request.subclass requestSerializerType];
    NSParameterAssert(requestSerializerType >= CHXRequestSerializerTypeHTTP);
    NSParameterAssert(requestSerializerType <= CHXRequestSerializerTypeJSON);
    
    switch (requestSerializerType) {
        case CHXRequestSerializerTypeJSON:
            self.sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
            break;
        default:
            self.sessionManager.requestSerializer = [AFHTTPRequestSerializer serializer];
            break;
    }
    
    self.sessionManager.requestSerializer.timeoutInterval = [request.subclass respondsToSelector:@selector(requestTimeoutInterval)] ?[request.subclass requestTimeoutInterval] : 10.0f;
}

- (void)pr_settingupResponseSerializerTypeByRequest:(CHXRequest *)request {
    CHXResponseSerializerType responseSerializerType = [request.subclass responseSerializerType];
    NSParameterAssert(responseSerializerType >= CHXResponseSerializerTypeHTTP);
    NSParameterAssert(responseSerializerType <= CHXResponseSerializerTypeImage);
    
    switch (responseSerializerType) {
        case CHXResponseSerializerTypeJSON:
            self.sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
            break;
        case CHXResponseSerializerTypeImage:
            self.sessionManager.responseSerializer = [AFImageResponseSerializer serializer];
            break;
        default:
            self.sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
            break;
    }
}

#pragma mark - Handle success

- (void)pr_handleRequestSuccessWithSessionDataTask:(NSURLSessionTask *)task responseObject:(id)responseObject {
    CHXRequest *request = [self.dataTaskContainer objectForKey:@(task.taskIdentifier)];
    NSParameterAssert(request);

    // If retrieve data using JSON, ignore this
    // If retrieve data using form binary data, provide a method convert to Foundation object
    responseObject = [request.subclass respondsToSelector:@selector(responseObjectFromRetrieveData:)] ? [request.subclass responseObjectFromRetrieveData:responseObject] : responseObject;
    NSParameterAssert(responseObject);

    request.responseObject = responseObject;

    [self pr_cacheIfNeededWithRequest:request responseObject:responseObject];
    [self pr_handleRequestSuccessWithRequest:request responseObject:responseObject];
    [self pr_prepareDeallocRequest:request];
}


- (id)pr_buildResponseObject:(id)responseObject forRequest:(CHXRequest *)request {
    NSString *responseCodeFieldName = [request.subclass responseCodeFieldName];
    NSParameterAssert(responseCodeFieldName);
    NSParameterAssert(responseCodeFieldName.length);
    
    NSString *responseResultFieldName = [request.subclass responseResultFieldName];
    NSParameterAssert(responseResultFieldName);
    NSParameterAssert(responseResultFieldName.length);
    
    NSDictionary *returnObject = @{responseCodeFieldName:@([request.subclass responseSuccessCodeValue]), responseResultFieldName:responseObject};
    
    return returnObject;
}

- (void)pr_handleRequestSuccessWithRequest:(CHXRequest *)request responseObject:(id)responseObject {
    NSString *responseCodeFieldName = [request.subclass responseCodeFieldName];
    NSParameterAssert(responseCodeFieldName);
    NSParameterAssert(responseCodeFieldName.length);
    
    NSInteger responseCode = [[responseObject objectForKey:responseCodeFieldName] integerValue];
    request.responseCode = responseCode;
    
    if (responseCode == [request.subclass responseSuccessCodeValue]) {
        NSString *responseResultFieldName = [request.subclass responseResultFieldName];
        NSParameterAssert(responseResultFieldName);
        NSParameterAssert(responseResultFieldName.length);
        request.responseSuccess = YES;
        
        id responseResult = [responseObject objectForKey:responseResultFieldName];
        request.responseResult = responseResult;
        if (self.debugMode) {
            NSLog(@"responseResult: %@", request.responseResult);
        }
    } else {
        NSString *responseMessageFieldName = [request.subclass responseMessageFieldName];
        NSParameterAssert(responseMessageFieldName);
        NSParameterAssert(responseMessageFieldName.length);
        
        id responseMessage = [responseObject objectForKey:responseMessageFieldName];
        request.responseMessage = responseMessage;
    }
    
    // Notify request complete
    [request notifyComplete];
}

#pragma mark - Handle failure

- (void)pr_handleRequestFailureWithSessionDataTask:(NSURLSessionTask *)task error:(NSError *)error {
    if (self.debugMode) {
        NSLog(@"Request failure with error: %@", CHXStringFromCFNetworkErrorCode(error.code));
    }
    
    CHXRequest *request = [self.dataTaskContainer objectForKey:@(task.taskIdentifier)];
    NSParameterAssert(request);
    
    request.responseMessage = [error localizedDescription];
    
    [request notifyComplete];
    
    [self pr_prepareDeallocRequest:request];
}

#pragma mark -

- (void)pr_prepareDeallocRequest:(CHXRequest *)request {
    // Remove contain from data task container
    [self pr_removeContainForRequest:request];
    
    // Break retain data task
    request.requestSessionTask = nil;
    
    request.command = nil;
    
    // Close networking activity indicator
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (void)pr_removeContainForRequest:(CHXRequest *)request {
    [self.dataTaskContainer removeObjectForKey:@(request.requestSessionTask.taskIdentifier)];
}

@end

