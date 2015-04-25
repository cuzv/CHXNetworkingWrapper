//
//  CHXPromoteProductListRequest.m
//  NWNetworkingWrapper
//
//  Created by Moch Xiao on 2015-04-16.
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

#import "CHXPromoteProductListRequest.h"

@interface CHXPromoteProductListRequest ()

@property (nonatomic, assign) NSInteger number;
@property (nonatomic, copy) NSString *type;

@end

@implementation CHXPromoteProductListRequest

- (instancetype)initWithNumber:(NSInteger)number type:(NSString *)type {
    if (self = [super init]) {
        _number = number;
        _type = type;
    }

    return self;
}


- (NSString *)requestModuleName {
    return @"Item";
}

- (NSString *)requestApiName {
    return @"getPromoteProductList";
}

- (NSArray *)requestSortedParmeters {
//    num	int	获取商品个数(不传默认为3)
//    type	string	促销类型(不传默认为index_best)
    return @[@(self.number), self.type];
}

- (BOOL)requestNeedCache {
    return NO;
}

- (NSTimeInterval)requestTimeoutInterval {
    return 2*60;
}




@end
