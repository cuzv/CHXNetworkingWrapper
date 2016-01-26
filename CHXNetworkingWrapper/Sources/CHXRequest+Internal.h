//
//  CHXRequest+Internal.h
//  CHXNetworkingWrapper
//
//  Created by Moch Xiao on 1/25/16.
//  Copyright © @2016 Moch Xiao (https://github.com/cuzv).
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

@interface CHXRequest ()

/// Server response object, generally contains `code`,  `result`, `message`
@property (nonatomic, strong, readwrite, nullable) id responseObject;

/// Response code
@property (nonatomic, assign, readwrite) NSInteger responseCode;

/// Retrieve result data, will be nil before the request notify complete
@property (nonatomic, strong, readwrite, nullable) id responseResult;

/// Retrieve error message, usuall be sent NSString
/// may be nil before the request notify complete
@property (nonatomic, strong, readwrite, nullable) id responseMessage;

/// Is the request response process succeed
@property (nonatomic, assign, readwrite) BOOL responseSuccess;


/// Notify the request is complete
/// No matter the request is success or failure, will invoke this method
- (void)notifyComplete;

@end
