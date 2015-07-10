//
//  CHXRequest+CHXRequestProxy.h
//  CHXNetworkingWrapper
//
//  Created by Moch Xiao on 7/11/15.
//  Copyright (c) 2015 Moch Xiao. All rights reserved.
//

#import "CHXRequest.h"

@interface CHXRequest (CHXRequestProxy)

/**
 *  Start a http request
 */
- (CHXRequest *)startRequest;

/**
 *  Stop the http request
 */
- (CHXRequest *)stopRequest;

/**
 *  Notify the request is complete
 *  Only invoke by `CHXRequestProxy`
 *  No matter the request is success or failure, will invoke this method
 */
- (CHXRequest *)notifyComplete;

@end
