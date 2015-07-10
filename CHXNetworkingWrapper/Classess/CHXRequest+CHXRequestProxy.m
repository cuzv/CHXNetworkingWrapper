//
//  CHXRequest+CHXRequestProxy.m
//  CHXNetworkingWrapper
//
//  Created by Moch Xiao on 7/11/15.
//  Copyright (c) 2015 Moch Xiao. All rights reserved.
//

#import "CHXRequest+CHXRequestProxy.h"
#import "CHXRequestProxy.h"

@interface CHXRequest ()
@property (nonatomic, strong) dispatch_queue_t queue;
@end

@implementation CHXRequest (CHXRequestProxy)

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
