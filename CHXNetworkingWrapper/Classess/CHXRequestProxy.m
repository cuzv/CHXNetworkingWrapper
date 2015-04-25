//
//  CHXRequestProxy.m
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

#import "CHXRequestProxy.h"
#import "AFNetworking.h"
#import "CHXMacro.h"
#import "CHXRequest.h"
#import "CHXResponseCache.h"
#import "CHXErrorCodeDescription.h"
#import "NSObject+ObjcRuntime.h"

#pragma mark -

const NSInteger kMaxConcurrentOperationCount = 8;

@interface CHXRequestProxy ()
@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;
@property (nonatomic, strong) NSMutableDictionary *dataTaskContainer;
@end

@implementation CHXRequestProxy

+ (instancetype)sharedInstance {
    static CHXRequestProxy *_sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [self new];
    });
    
    return _sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        _sessionManager = [AFHTTPSessionManager manager];
        _sessionManager.operationQueue.maxConcurrentOperationCount = kMaxConcurrentOperationCount;
        [_sessionManager.reachabilityManager startMonitoring];
        [_sessionManager.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            NSLog(@"AFNetworkReachabilityStatus: %@", AFStringFromNetworkReachabilityStatus(status));
        }];
        _dataTaskContainer = [NSMutableDictionary new];
        // When background download file complete, but move to target path failure, will post this notification
        [[NSNotificationCenter defaultCenter] addObserverForName:AFURLSessionDownloadTaskDidFailToMoveFileNotification object:nil queue:[NSOperationQueue currentQueue] usingBlock:^(NSNotification *note) {
            NSLog(@"AFURLSessionDownloadTaskDidFailToMoveFileNotification = %@", note);
        }];
    }
    
    return self;
}

/**
 *  `AFNetworkReachabilityManager` first request network status is always `AFNetworkReachabilityStatusUnknown`
 *  So, let it checking before formal request by start a invalid request.
 */
+ (void)load {
    [[CHXRequestProxy sharedInstance] addRequest:[CHXRequest new]];
}

#pragma mark -

- (void)addRequest:(CHXRequest *)request {
    // Checking Networking status
    if (![self pr_isNetworkReachable]) {
        // If cache exist, return cache data
        if (![self pr_shouldContinueRequest:request]) {
            return;
        }
        
        // The first time description is not correct !
        NSLog(@"The network is currently unreachable.");
        
        // Notify request complete
        [request notifyComplete];
        
        return;
    }
    
    // Start request
    NSURLSessionTask *dataTask = nil;
    NSDictionary *requestParameters = nil;
    
    NSURLRequest *customRULRequest = [request customURLRequest];
    if (customRULRequest) {
        NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        AFURLSessionManager *sessionManager = [[AFURLSessionManager alloc] initWithSessionConfiguration:sessionConfiguration];
        dataTask = [sessionManager dataTaskWithRequest:customRULRequest completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
            if (error) {
                [self pr_handleRequestFailureWithSessionDataTask:dataTask error:error];
            } else {
                [self pr_handleRequestSuccessWithSessionDataTask:dataTask responseObject:responseObject];
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
        CHXRequestMethod requestMethod = [request requestMehtod];
        NSAssert(requestMethod <= CHXRequestMethodHead, @"Unsupport Request Method");
        NSAssert(requestMethod >= CHXRequestMethodPost, @"Unsupport Request Method");
        
        // HTTP API absolute URL
        NSString *requestAbsoluteURLString = [request requestURLString];
        NSParameterAssert(requestAbsoluteURLString);
        NSParameterAssert(requestAbsoluteURLString.length);
        
        // HTTP POST value block
        AFConstructingBlock constructingBodyBlock = [request constructingBodyBlock];
        
        // SerializerType
        [self pr_settingupRequestSerializerTypeByRequest:request];
        [self pr_settingupResponseSerializerTypeByRequest:request];
        
        // HTTP Request parameters
        requestParameters = [request requestParameters];
        NSParameterAssert(requestParameters);

        // Open networking activity indicator
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
        switch (requestMethod) {
            case CHXRequestMethodPost: {
                if (constructingBodyBlock) {
                    dataTask = [_sessionManager POST:requestAbsoluteURLString parameters:requestParameters constructingBodyWithBlock:constructingBodyBlock success:^(NSURLSessionDataTask *task, id responseObject) {
                        [self pr_handleRequestSuccessWithSessionDataTask:task responseObject:responseObject];
                    } failure:^(NSURLSessionDataTask *task, NSError *error) {
                        [self pr_handleRequestFailureWithSessionDataTask:task error:error];
                    }];
                } else {
                    dataTask = [_sessionManager POST:requestAbsoluteURLString parameters:requestParameters success:^(NSURLSessionDataTask *task, id responseObject) {
                        [self pr_handleRequestSuccessWithSessionDataTask:task responseObject:responseObject];
                    } failure:^(NSURLSessionDataTask *task, NSError *error) {
                        [self pr_handleRequestFailureWithSessionDataTask:task error:error];
                    }];
                }
            }
                break;
            case CHXRequestMethodGet: {
                NSString *downloadTargetFilePath = [request downloadTargetFilePathString];
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
                            [self pr_handleRequestFailureWithSessionDataTask:request.requestSessionTask error:error];
                        } else {
                            id object = [self pr_buildResponseObject:filePath forRequest:request];
                            [self pr_handleRequestSuccessWithSessionDataTask:request.requestSessionTask responseObject:object];
                        }
                    }];
                    // If download on background
                    [sessionManager setDownloadTaskDidFinishDownloadingBlock:^NSURL *(NSURLSession *session, NSURLSessionDownloadTask *downloadTask, NSURL *location) {
                        return [NSURL URLWithString:downloadTargetFilePath];
                    }];
                    [dataTask resume];
                } else {
                    dataTask = [_sessionManager GET:requestAbsoluteURLString parameters:requestParameters success:^(NSURLSessionDataTask *task, id responseObject) {
                        [self pr_handleRequestSuccessWithSessionDataTask:task responseObject:responseObject];
                    } failure:^(NSURLSessionDataTask *task, NSError *error) {
                        [self pr_handleRequestFailureWithSessionDataTask:task error:error];
                    }];
                }
            }
                break;
            case CHXRequestMethodPut: {
                dataTask = [_sessionManager PUT:requestAbsoluteURLString parameters:requestParameters success:^(NSURLSessionDataTask *task, id responseObject) {
                    [self pr_handleRequestSuccessWithSessionDataTask:task responseObject:responseObject];
                } failure:^(NSURLSessionDataTask *task, NSError *error) {
                    [self pr_handleRequestFailureWithSessionDataTask:task error:error];
                }];
            }
                break;
            case CHXRequestMethodDelete: {
                dataTask = [_sessionManager DELETE:requestAbsoluteURLString parameters:requestParameters success:^(NSURLSessionDataTask *task, id responseObject) {
                    [self pr_handleRequestSuccessWithSessionDataTask:task responseObject:responseObject];
                } failure:^(NSURLSessionDataTask *task, NSError *error) {
                    [self pr_handleRequestFailureWithSessionDataTask:task error:error];
                }];
            }
                break;
            case CHXRequestMethodPatch: {
                dataTask = [_sessionManager PATCH:requestAbsoluteURLString parameters:requestParameters success:^(NSURLSessionDataTask *task, id responseObject) {
                    [self pr_handleRequestSuccessWithSessionDataTask:task responseObject:responseObject];
                } failure:^(NSURLSessionDataTask *task, NSError *error) {
                    [self pr_handleRequestFailureWithSessionDataTask:task error:error];
                }];
            }
                break;
            case CHXRequestMethodHead: {
                dataTask = [_sessionManager HEAD:requestAbsoluteURLString parameters:requestAbsoluteURLString success:^(NSURLSessionDataTask *task) {
                    [self pr_handleRequestSuccessWithSessionDataTask:task responseObject:nil];
                } failure:^(NSURLSessionDataTask *task, NSError *error) {
                    [self pr_handleRequestFailureWithSessionDataTask:task error:error];
                }];
            }
                break;
            default:
                break;
        }
    }
    
    // Connect Request and Data task
    request.requestSessionTask = dataTask;
    
    // Record the request task
    _dataTaskContainer[@(dataTask.taskIdentifier)] = request;
    
    // For debug
    NSLog(@"Request URL = %@", dataTask.currentRequest.URL);
    NSLog(@"Request parameters = %@", requestParameters);
    NSLog(@"Request Http header fields = %@", dataTask.currentRequest.allHTTPHeaderFields);
}

- (void)removeRequest:(CHXRequest *)request {
    [request.requestSessionTask cancel];
    [request notifyComplete];
    [self pr_prepareDeallocRequest:request];
}

- (void)removeAllRequest {
    [_sessionManager.operationQueue cancelAllOperations];
    
    __weak typeof(self) weakSelf = self;
    [self.dataTaskContainer enumerateKeysAndObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id key, id obj, BOOL *stop) {
        if ([obj isKindOfClass:[CHXRequest class]]) {
            CHXRequest *request = (CHXRequest *)obj;
            [weakSelf removeRequest:request];
        }
    }];
}

#pragma mark -

- (BOOL)pr_isNetworkReachable {
    return [_sessionManager.reachabilityManager isReachable];
}

- (BOOL)pr_shouldContinueRequest:(CHXRequest *)request {
    // Need cache ?
    if (![request requestNeedCache]) {
        return YES;
    }
    
    // If cache data not exist, should continure request
    CHXResponseCache *cacheResponse = [self pr_cacheForRequest:request];
    if (!cacheResponse.cahceResponseObject || !cacheResponse.cacheDate) {
        return YES;
    }
    
    NSTimeInterval interval = -[cacheResponse.cacheDate timeIntervalSinceNow];
    NSTimeInterval duration = request.requestCacheDuration;
    if (interval > duration) {
        return YES;
    }
    // handle request success
    [self pr_handleRequestSuccessWithRequest:request responseObject:cacheResponse.cahceResponseObject];
    
    // dealloc request
    [self pr_prepareDeallocRequest:request];
    
    NSLog(@"Retrieve data from cache.");
    
    return NO;
}

- (CHXResponseCache *)pr_cacheForRequest:(CHXRequest *)request {
    // Retrieve cache data
    NSString *filePath = [self pr_cacheFilePathStringForReqeust:request];
    CHXResponseCache *cache = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
    
    return cache;
}

- (void)pr_cacheIfNeededWithRequest:(CHXRequest *)request responseObject:(id)responseObject {
    if (![request requestNeedCache]) {
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
    NSString *originalURLString = [request requestURLString];
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
    NSDictionary *parameters = request.requestParameters;
    
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
    CHXRequestSerializerType requestSerializerType = [request requestSerializerType];
    NSParameterAssert(requestSerializerType >= CHXRequestSerializerTypeHTTP);
    NSParameterAssert(requestSerializerType <= CHXRequestSerializerTypeJSON);
    
    switch (requestSerializerType) {
        case CHXRequestSerializerTypeJSON:
            _sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
            break;
        default:
            _sessionManager.requestSerializer = [AFHTTPRequestSerializer serializer];
            break;
    }
    
    _sessionManager.requestSerializer.timeoutInterval = [request requestTimeoutInterval];
}

- (void)pr_settingupResponseSerializerTypeByRequest:(CHXRequest *)request {
    CHXResponseSerializerType responseSerializerType = [request responseSerializerType];
    NSParameterAssert(responseSerializerType >= CHXResponseSerializerTypeHTTP);
    NSParameterAssert(responseSerializerType <= CHXResponseSerializerTypeImage);
    
    switch (responseSerializerType) {
        case CHXResponseSerializerTypeJSON:
            _sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
            break;
        case CHXResponseSerializerTypeImage:
            _sessionManager.responseSerializer = [AFImageResponseSerializer serializer];
            break;
        default:
            _sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
            break;
    }
}

- (void)pr_handleRequestSuccessWithSessionDataTask:(NSURLSessionTask *)task responseObject:(id)responseObject {
    NSLog(@"Request successed");
    CHXRequest *request = [_dataTaskContainer objectForKey:@(task.taskIdentifier)];
    NSParameterAssert(request);

    // If retrieve data using JSON, ignore this
    // If retrieve data using form binary data, provide a method convert to Foundation object
    responseObject = [request responseObjectFromRetrieveData:responseObject];
    NSParameterAssert(responseObject);

    [self pr_cacheIfNeededWithRequest:request responseObject:responseObject];
    [self pr_handleRequestSuccessWithRequest:request responseObject:responseObject];
    [self pr_prepareDeallocRequest:request];
}


- (id)pr_buildResponseObject:(id)responseObject forRequest:(CHXRequest *)request {
    NSString *responseCodeFieldName = [request responseCodeFieldName];
    NSParameterAssert(responseCodeFieldName);
    NSParameterAssert(responseCodeFieldName.length);
    
    NSString *responseDataFieldName = [request responseDataFieldName];
    NSParameterAssert(responseDataFieldName);
    NSParameterAssert(responseDataFieldName.length);
    
    NSDictionary *returnObject = @{responseCodeFieldName:@([request responseSuccessCodeValue]), responseDataFieldName:responseObject};
    
    return returnObject;
}

- (void)pr_handleRequestSuccessWithRequest:(CHXRequest *)request responseObject:(id)responseObject {
    NSString *responseCodeFieldName = [request responseCodeFieldName];
    NSParameterAssert(responseCodeFieldName);
    NSParameterAssert(responseCodeFieldName.length);
    
    NSInteger responseCode = [[responseObject objectForKey:responseCodeFieldName] integerValue];
    request.responseCode = responseCode;
    
    if (responseCode == [request responseSuccessCodeValue]) {
        NSString *responseDataFieldName = [request responseDataFieldName];
        NSParameterAssert(responseDataFieldName);
        NSParameterAssert(responseDataFieldName.length);
        request.responseSuccess = YES;
        
        id responseData = [responseObject objectForKey:responseDataFieldName];
        request.responseObject = responseData;
#if DEBUG
        NSLog(@"responseObject = %@", request.responseObject);
#endif
    } else {
        NSString *responseMessageFieldName = [request responseMessageFieldName];
        NSParameterAssert(responseMessageFieldName);
        NSParameterAssert(responseMessageFieldName.length);
        
        id responseMessage = [responseObject objectForKey:responseMessageFieldName];
        request.errorMessage = responseMessage;
    }
    
    // Notify request complete
    [request notifyComplete];
}

- (void)pr_handleRequestFailureWithSessionDataTask:(NSURLSessionTask *)task error:(NSError *)error {
    NSLog(@"Request error: %@", CHXStringFromCFNetworkErrorCode(error.code));
    
    CHXRequest *request = [_dataTaskContainer objectForKey:@(task.taskIdentifier)];
    NSParameterAssert(request);
    
    request.errorMessage = [error localizedDescription];
    
    [request notifyComplete];
    
    [self pr_prepareDeallocRequest:request];
}

- (void)pr_prepareDeallocRequest:(CHXRequest *)request {
    // Remove contain from data task container
    [self pr_removeContainForRequest:request];
    
    // Break retain data task
    request.requestSessionTask = nil;
    
    // Close networking activity indicator
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (void)pr_removeContainForRequest:(CHXRequest *)request {
    [_dataTaskContainer removeObjectForKey:@(request.requestSessionTask.taskIdentifier)];
}

@end

