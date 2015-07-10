//
//  CHXRequestEnum.h
//  CHXNetworkingWrapper
//
//  Created by Moch Xiao on 7/10/15.
//  Copyright (c) 2015 Moch Xiao. All rights reserved.
//

#ifndef CHXNetworkingWrapper_CHXRequestEnum_h
#define CHXNetworkingWrapper_CHXRequestEnum_h

// HTTP Method
typedef NS_ENUM(NSInteger, CHXRequestMethod) {
    CHXRequestMethodPost = 0,
    CHXRequestMethodGet,
    CHXRequestMethodPut,
    CHXRequestMethodDelete,
    CHXRequestMethodPatch,
    CHXRequestMethodHead
};

typedef NS_ENUM(NSInteger, CHXRequestSerializerType) {
    CHXRequestSerializerTypeHTTP = 0,
    CHXRequestSerializerTypeJSON
};

typedef NS_ENUM(NSInteger, CHXResponseSerializerType) {
    CHXResponseSerializerTypeHTTP = 0,
    CHXResponseSerializerTypeJSON,
    CHXResponseSerializerTypeImage
};

#endif
