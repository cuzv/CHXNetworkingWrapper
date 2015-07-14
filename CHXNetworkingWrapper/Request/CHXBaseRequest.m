//
//  CHXBaseRequest.m
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

#import "CHXBaseRequest.h"
#import "NSDataExtension.h"
#import "NSString+MD5.h"
#import "CHXNetworkingWrapper.h"

static const NSString *kUser = @"haioo";
NSString * const kSecrectKey = @"Ka48qGTlf00PSoNnZwM3Rx8PG2oOs1RK";

//NSString * const ApiURLForDebug = @"testapi.haioo.com/";
NSString * const ApiURLForDebug = @"api.haioo.com/";
NSString * const ApiURLForRelease = @"api.haioo.com/";

#if DEBUG
    #define APIURL ApiURLForDebug
#else
    #define APIURL ApiURLForRelease
#endif


@implementation CHXBaseRequest

- (id <CHXRequestCommandProtocol>)command {
    return [CHXRequestCommand sharedInstance];
}

#pragma mark - CHXRequestConstructProtocol

- (NSString *)requestURLPath {
    NSMutableString *url = [NSMutableString new];
    [url appendString:@"http://"];
    [url appendString:[self requestModuleName]];
    [url appendString:@"."];
    [url appendString:APIURL];
    [url appendString:[self requestApiVersion]];

    return [NSString stringWithString:url];
}

// 版本号
- (NSString *)requestApiVersion {
    return @"v2";
}

- (NSDictionary *)requestParameters {
    NSDictionary *dict = @{@"data": [self pr_actualRequestParams],
                           @"signature": [self pr_requestSignature]};
    NSLog(@"request params = %@", dict);

    // convert to JSON
    NSData *jsonData = [NSData chx_dataWithJSONObject:dict];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

    return @{@"data": jsonString};
}

- (CHXRequestMethod)requestMethod {
    return CHXRequestMethodPost;
}

- (CHXRequestSerializerType)requestSerializerType {
    return CHXRequestSerializerTypeHTTP;
}

- (BOOL)requestDemandCache {
    return NO;
}

#pragma mark - CHXRequestRetrieveProtocol

- (CHXResponseSerializerType)responseSerializerType {
    return CHXResponseSerializerTypeHTTP;
}

- (NSString *)responseCodeFieldName {
    return @"code";
}

- (NSInteger)responseSuccessCodeValue {
    return 0;
}

- (NSString *)responseResultFieldName {
    return @"result";
}

- (NSString *)responseMessageFieldName {
    return @"msg";
}

- (id)responseObjectFromRetrieveData:(id)data {
    return [data chx_JSONObject];
}

#pragma mark - Private

- (NSString *)pr_requestSignature {
    NSString *params = [self pr_stringWithArray:[self requestSortedParmeters]];
    NSMutableDictionary *actualRequestParams = [[self pr_actualRequestParams] mutableCopy];
    [actualRequestParams setObject:params forKey:@"params"];

    NSMutableString *beforeEncode = [NSMutableString new];
    [actualRequestParams enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [beforeEncode appendFormat:@"%@=%@", key, obj];
    }];
    [beforeEncode appendString:kSecrectKey];

    NSString *afterEncode = [beforeEncode MD5Digest];

    return afterEncode;
}

- (NSString *)pr_stringWithArray:(NSArray *)items {
    if (!items.count) {
        return @"";
    }

    NSMutableString *content = [NSMutableString new];
    for (id item in items) {
        [content appendFormat:@"%@,", item];
    }
    [content deleteCharactersInRange:NSMakeRange(content.length - 1, 1)];

    return [NSString stringWithFormat:@"%@", content];
}

- (NSDictionary *)pr_actualRequestParams {
    NSDictionary *params = @{@"user": kUser,
                             @"classname": [self requestModuleName],
                             @"method": [self requestApiName],
                             @"params": [self requestSortedParmeters]};
    return params;
}

#pragma mark - Subclass override

- (NSString *)requestModuleName {
    return nil;
}

- (NSString *)requestApiName {
    return nil;
}

- (NSArray *)requestSortedParmeters {
    return nil;
}






@end
