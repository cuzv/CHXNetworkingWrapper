//
//  CHXDownLoadRequest.h
//  CHXNetworkingWrapper
//
//  Created by Moch Xiao on 5/18/15.
//  Copyright (c) 2015 Moch Xiao. All rights reserved.
//

#import "CHXRequest.h"

@interface CHXDownLoadRequest : CHXRequest
- (instancetype)initWithDownloadProgress:(void(^)(CGFloat progress))downloadProgress;
@end
