//
//  CHXResponseable.h
//  CHXNetworkingWrapper
//
//  Created by Moch Xiao on 1/20/16.
//  Copyright © @2014 Moch Xiao (https://github.com/cuzv).
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import <Foundation/Foundation.h>
#import "CHXNetworkingWrapperDefine.h"

typedef _Nonnull id(^ConvertResponseHandler)(_Nonnull id);

@protocol CHXResponseable <NSObject>

@required

/// The response code field name.
- (nonnull NSString *)responseCodeFieldName;

/// The response succes code value
- (NSInteger)responseSuccessCodeValue;

/// The response result field name.
- (nonnull NSString *)responseResultFieldName;

/// The response message field name.
- (nonnull NSString *)responseMessageFieldName;

@optional

/// The response encoding type.
- (CHXResponseEncoding)responseEncoding;

/// Convert HTTP response data to Foundation object
- (nullable ConvertResponseHandler)convertResponseHandler;

@end
