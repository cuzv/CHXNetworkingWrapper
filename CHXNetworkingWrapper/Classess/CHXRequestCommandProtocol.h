//
//  CHXRequestCommandProtocol.h
//  CHXNetworkingWrapper
//
//  Created by Moch Xiao on 7/13/15.
//  Copyright (c) 2015 Moch Xiao. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CHXRequest;

@protocol CHXRequestCommandProtocol <NSObject>

/// Add a request task
- (void)addRequest:(CHXRequest *)request;

/// Cancel request task
- (void)removeRequest:(CHXRequest *)request;

/// Cancel all request task
- (void)removeAllRequest;

@end
