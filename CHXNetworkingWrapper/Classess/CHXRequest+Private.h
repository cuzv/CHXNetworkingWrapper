//
//  CHXRequest+Private.h
//  CHXNetworkingWrapper
//
//  Created by Moch Xiao on 7/14/15.
//  Copyright (c) 2015 Moch Xiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CHXRequest.h"

@interface CHXRequest ()

// This transfer protocol methods response to subclass
@property (nonatomic, weak, readonly) id <CHXRequestConstructProtocol, CHXRequestRetrieveProtocol> subclass;

// When networking is not reachable, retry after 1s, this record how many times have tried.
@property (nonatomic, assign) NSUInteger currentRetryCount;

// Hold on request task, only invoke by `CHXRequestCommand`
@property (nonatomic, strong) NSURLSessionTask *requestSessionTask;

/**
 *  Initialze dispatch_queue
 *
 *  @return Self
 */
- (CHXRequest *)initializeQueueIfNeeded;

/**
 *  Notify the request is complete
 *  Only invoke by `CHXRequestCommand`
 *  No matter the request is success or failure, will invoke this method
 *
 *  @return Self
 */
- (CHXRequest *)notifyComplete;

@end

