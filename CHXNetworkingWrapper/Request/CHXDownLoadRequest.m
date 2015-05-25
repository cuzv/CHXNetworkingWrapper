//
//  CHXDownLoadRequest.m
//  CHXNetworkingWrapper
//
//  Created by Moch Xiao on 5/18/15.
//  Copyright (c) 2015 Moch Xiao. All rights reserved.
//

#import "CHXDownLoadRequest.h"

@interface CHXDownLoadRequest ()
@property (nonatomic, copy) void (^downloadProgress)(CGFloat progress);

@end

@implementation CHXDownLoadRequest

- (instancetype)initWithDownloadProgress:(void(^)(CGFloat progress))downloadProgress {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _downloadProgress = downloadProgress;
    
    return self;
}

- (NSDictionary *)requestParameters {
    return @{};
}

- (NSString *)requestURLString {
    return @"http://pic.miercn.com/uploads/allimg/150518/40-15051Q51345.jpg";
}

- (NSString *)downloadTargetFilePathString {
    
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSLog(@"documentPath = %@", documentPath);
    return [documentPath stringByAppendingString:@"/download.jpg"];
}

- (CHXRequestMethod)requestMehtod {
    return CHXRequestMethodGet;
}

- (void (^)(CGFloat))downloadProgress {
    return _downloadProgress;
}

- (NSString *)responseCodeFieldName {
    return @"code";
}

- (NSInteger)responseSuccessCodeValue {
    return 0;
}

- (NSString *)responseDataFieldName {
    return @"result";
}

- (NSString *)responseMessageFieldName {
    return @"msg";
}


@end