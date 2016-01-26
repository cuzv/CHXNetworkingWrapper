//
//  CHXDownLoadRequest.m
//  CHXNetworkingWrapper
//
//  Created by Moch Xiao on 5/18/15.
//  Copyright (c) 2015 Moch Xiao. All rights reserved.
//

#import "CHXDownLoadRequest.h"
#import "CHXNetworkingWrapper.h"

@interface CHXDownLoadRequest ()
@property (nonatomic, copy) void (^downloadProgress)(CGFloat progress);

@end

@implementation CHXDownLoadRequest

- (void)dealloc {
    NSLog(@"%s", __FUNCTION__);
}

- (id)requestCommand {
    return [CHXAFCommand new];
}

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

- (NSString *)requestURLPath {
    return @"http://pic14.nipic.com/20110522/7411759_164157418126_2.jpg";
}

- (NSString *)downloadTargetFilePath {
    
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSLog(@"documentPath = %@", documentPath);
    return [documentPath stringByAppendingString:@"/download.jpg"];
}

- (CHXRequestMethod)requestMethod {
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

- (NSString *)responseResultFieldName {
    return @"result";
}

- (NSString *)responseMessageFieldName {
    return @"msg";
}

- (CHXParameterEncoding)requestParameterEncoding {
    return CHXParameterEncodingURL;
}

- (CHXResponseEncoding)responseEncoding {
    return CHXResponseEncodingForm;
}

@end
