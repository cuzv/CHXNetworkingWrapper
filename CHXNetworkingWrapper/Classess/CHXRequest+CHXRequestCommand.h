//
//  CHXRequest+CHXRequestCommand.h
//  CHXNetworkingWrapper
//
//  Created by Moch Xiao on 7/11/15.
//  Copyright (c) 2015 Moch Xiao. All rights reserved.
//

#import "CHXRequest.h"

@interface CHXRequest (CHXRequestCommand)

/**
 *  Start a http request
 *
 *  @return Self
 */
- (CHXRequest *)startRequest;

/**
 *  Stop the http request
 *
 *  @return Self
 */
- (CHXRequest *)stopRequest;

/**
 *  Stop all the http request
 *
 *  @return Self
 */
- (CHXRequest *)stopAllRequest;


@end
