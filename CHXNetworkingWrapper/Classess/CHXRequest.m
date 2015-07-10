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
@property (nonatomic, weak, readwrite) id <CHXRequestConstructProtocol, CHXRequestRetrieveProtocol> subclass;
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

// Make subclass conforms CHXRequestConstructProtocol

- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    if ([self conformsToProtocol:@protocol(CHXRequestConstructProtocol)] &&
        [self conformsToProtocol:@protocol(CHXRequestRetrieveProtocol)]) {
        self.subclass = (id <CHXRequestConstructProtocol, CHXRequestRetrieveProtocol>) self;
    } else {
        NSAssert(NO, @"subclass must conforms CHXRequestConstructProtocol and CHXRequestRetrieveProtocol");
    }
    
    return self;
}

@end
