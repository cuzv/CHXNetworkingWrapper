//
//  CHXRequestRetrieveProtocol.h
//  CHXNetworkingWrapper
//
//  Created by Moch Xiao on 7/10/15.
//  Copyright (c) 2015 Moch Xiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CHXRequestEnum.h"

@protocol CHXRequestRetrieveProtocol <NSObject>

@required

/// Get response serizlizer type, defined by API maker
- (CHXResponseSerializerType)responseSerializerType;

/// Get the retrieve code api field name
- (NSString *)responseCodeFieldName;

/// Get the response success code field name
- (NSInteger)responseSuccessCodeValue;

/// Get the retrieve result api field name
- (NSString *)responseResultFieldName;

/// Get the retrieve message api field name
- (NSString *)responseMessageFieldName;

@optional

/// Convert HTTP response data to Foundation object
/// If retrieve data using JSON, ignore this
/// If retrieve data using form binary data, provide a method convert to Foundation object
- (id)responseObjectFromRetrieveData:(id)data;

@end
