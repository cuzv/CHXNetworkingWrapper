//
//  CHXRequest+Global.m
//  CHXNetworkingWrapper
//
//  Created by Moch Xiao on 7/13/15.
//  Copyright (c) 2015 Moch Xiao. All rights reserved.
//

#import "CHXRequest+Global.h"
#import "CHXRequestCommand.h"

@implementation CHXRequest (Global)

- (id <CHXRequestCommandProtocol>)command {
    return [CHXRequestCommand sharedInstance];
}

@end
