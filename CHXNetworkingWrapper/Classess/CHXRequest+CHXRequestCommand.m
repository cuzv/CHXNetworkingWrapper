//
//  CHXRequest+CHXRequestCommand.m
//  CHXNetworkingWrapper
//
//  Created by Moch Xiao on 7/11/15.
//  Copyright (c) 2015 Moch Xiao. All rights reserved.
//

#import "CHXRequest+CHXRequestCommand.h"
#import "CHXRequestCommand.h"
#import "CHXRequest+Private.h"

@interface CHXRequest ()
@end

@implementation CHXRequest (CHXRequestCommand)

- (CHXRequest *)startRequest {
    [self initializeQueueIfNeeded];
    
    [self.command addRequest:self];
    return self;
}

- (CHXRequest *)stopRequest {
    [self.command removeRequest:self];
    return self;
}

- (CHXRequest *)stopAllRequest {
    [self.command removeAllRequest];
    return self;
}


@end
