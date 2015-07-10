//
//  CHXRequest.m
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

#import "CHXRequest.h"
#import "CHXRequestProxy.h"
#import "CHXMacro.h"
#import "NSObject+ObjcRuntime.h"

@interface CHXRequest ()
@property (nonatomic, strong) dispatch_queue_t queue;
@end

@implementation CHXRequest

#pragma mark - Hash

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    
    NSArray *propertyArray = [self objc_properties];
    __block BOOL euqal = YES;
    [propertyArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        id selfObject = [self valueForKey:obj];
        id compareObject = [object valueForKey:obj];
        euqal = [selfObject isEqual:compareObject];
        
        if (!euqal && selfObject && compareObject) {
            *stop = YES;
        } else {
            euqal = YES;
        }
    }];
    
    return euqal;
}

- (NSUInteger)hash {
    NSArray *propertyArray = [self objc_properties];
    __block NSUInteger hashCode = 0;
    [propertyArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        hashCode ^= [[self valueForKey:obj] hash];
    }];
    
    return hashCode;
}

@end

#pragma mark - Subclass should overwrite

#pragma mark - Request Construct data

@implementation CHXRequest (CHXConstruct)

- (NSDictionary *)requestParameters {
    return nil;
}

- (NSString *)requestURLString {
    return nil;
}

- (CHXRequestMethod)requestMehtod {
    return CHXRequestMethodPost;
}

- (CHXRequestSerializerType)requestSerializerType {
    return CHXRequestSerializerTypeHTTP;
}

- (AFConstructingBlock)constructingBodyBlock {
    return nil;
}

- (NSString *)downloadTargetFilePathString {
    return nil;
}

- (void(^)(CGFloat progress))downloadProgress {
    return nil;
}

- (void(^)(CGFloat progress))uploadProgress {
    return nil;
}


- (NSURLRequest *)customURLRequest {
    return nil;
}

- (NSTimeInterval)requestTimeoutInterval {
    return 10;
}

- (BOOL)requestNeedCache {
    return NO;
}

- (NSTimeInterval)requestCacheDuration {
    return 60 * 3;
}

@end

#pragma mark - Retrieve response data

@implementation CHXRequest (CHXRetrieve)

- (CHXResponseSerializerType)responseSerializerType {
    return CHXResponseSerializerTypeJSON;
}

- (NSString *)responseDataFieldName {
    return nil;
}

- (NSString *)responseCodeFieldName {
    return nil;
}

- (NSInteger)responseSuccessCodeValue {
    return 0;
}

- (NSString *)responseMessageFieldName {
    return nil;
}

- (id)responseObjectFromRetrieveData:(id)data {
    return data;
}

@end

#pragma mark - Perform

@implementation CHXRequest (CHXPerform)

- (CHXRequest *)stopRequest {
    [[CHXRequestProxy sharedInstance] removeRequest:self];
    
    return self;
}

- (CHXRequest *)startRequest {
    [self initializeQueueIfNeeded];
    
    [[CHXRequestProxy sharedInstance] addRequest:self];
    
    return self;
}

- (void)initializeQueueIfNeeded {
    if (self.queue) {
        return;
    }
    
    self.queue = ({
        NSString *queueLabel = [NSString stringWithFormat:@"xiao.moch.queueidentifier.%zd", [self hash]];
        dispatch_queue_t queue = dispatch_queue_create([queueLabel UTF8String], DISPATCH_QUEUE_SERIAL);
        dispatch_suspend(queue);
        queue;
    });
}

- (CHXRequest *)notifyComplete {
    if (self.queue) {
        dispatch_resume(self.queue);
    }
    
    return self;
}

@end

#pragma mark - Done asynchronously

@implementation CHXRequest (CHXAsynchronously)

- (CHXRequest *)successCompletionResponse:(RequestSuccessCompletionBlock)requestSuccessCompletionBlock {
    dispatch_async(self.queue, ^{
        requestSuccessCompletionBlock(self.responseObject);
    });
    
    return self;
}

- (CHXRequest *)failureCompletionResponse:(RequestFailureCompletionBlock)requestFailureCompletionBlock {
    dispatch_async(self.queue, ^{
        requestFailureCompletionBlock(self.errorMessage);
    });
    
    return self;
}

- (CHXRequest *)completionResponse:(RequestCompletionBlock)requestCompletionBlock {
    dispatch_async(self.queue, ^{
        requestCompletionBlock(self.responseObject, self.errorMessage);
    });
    
    return self;
}

- (CHXRequest *)completionHandle:(RequestCompletionHandle)requestCompletionHandle {
    dispatch_async(self.queue, ^{
        requestCompletionHandle(self);
    });
    
    return self;
}

@end

#pragma mark - Convenience

@implementation CHXRequest (CHXConvenience)

- (CHXRequest *)startRequestWithSuccess:(RequestSuccessCompletionBlock)requestSuccessCompletionBlock failue:(RequestFailureCompletionBlock)requestFailureCompletionBlock {
    [self startRequest];
    
    dispatch_async(self.queue, ^{
        if (self.responseSuccess) {
            requestSuccessCompletionBlock(self.responseObject);
        } else {
            requestFailureCompletionBlock(self.errorMessage);
        }
    });
    
    return self;
}

@end