//
//  CHXDownLoadRequest.h
//  CHXNetworkingWrapper
//
//  Created by Moch Xiao on 5/18/15.
//  Copyright (c) 2015 Moch Xiao. All rights reserved.
//

#import "CHXRequest.h"
#import "CHXBaseRequest.h"
#import "CHXNetworkingWrapper.h"

@interface CHXDownLoadRequest : CHXRequest <CHXRequestable, CHXResponseable>
- (instancetype)initWithDownloadProgress:(void(^)(CGFloat progress))downloadProgress;
@end
