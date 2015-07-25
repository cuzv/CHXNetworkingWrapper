//
//  CHXRequest.h
//  CHXNetworkingWrapper
//
//  Created by Moch Xiao on 2015-04-19.
//  Copyright (c) 2014 Moch Xiao (https://github.com/atcuan).
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
#import "AFNetworking.h"
#import "CHXRequestConstructProtocol.h"
#import "CHXRequestRetrieveProtocol.h"
#import "CHXRequestCommandProtocol.h"

#pragma mark - CHXRequest

/// This class collection a request infos what needed, by subclass and override methods
@interface CHXRequest : NSObject

/// The command, Before start requst, inject command first
@property (nonatomic, weak) id <CHXRequestCommandProtocol> command;

@end

#pragma mark - CHXRequestCommand retrieve data

@interface CHXRequest ()

/// Server response object, generally contains `code`,  `result`, `message`
@property (nonatomic, strong) id responseObject;


/// Response code
/// `[CHXRequestRetrieveProtocol] responseCodeFieldName` value
@property (nonatomic, assign) NSInteger responseCode;

/// Retrieve result data, will be nil before the request notify complete
/// `[CHXRequestRetrieveProtocol] responseResultFieldName` value
@property (nonatomic, strong) id responseResult;

/// Retrieve error message, usuall be sent NSString
/// may be nil before the request notify complete
/// `[CHXRequestRetrieveProtocol] responseMessageFieldName` value
@property (nonatomic, strong) id responseMessage;

/// Is the request response process succeed
@property (nonatomic, assign) BOOL responseSuccess;

@end
