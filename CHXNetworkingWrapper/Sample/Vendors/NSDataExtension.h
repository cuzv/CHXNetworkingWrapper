//
//  NSDataExtension.h
//  GettingStarted
//
//  Created by Moch Xiao on 2014-11-20.
//  Copyright (c) 2014 Moch Xiao (https://github.com/cuzv).
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

@interface NSDataExtension : NSObject

@end


@interface NSData (CHXJSON)

/**
 *  Create a Foundation object from JSON data
 *
 *  @return Foundation object
 */
- (id)chx_JSONObject;

/**
 *  Generate JSON data from a Foundation object
 *
 *  @param object Foundation object
 *
 *  @return JSON data
 */
+ (NSData *)chx_dataWithJSONObject:(id)object;

/**
 *  Generate an JSON data from a property list
 *
 *  @param plist property list
 *
 *  @return JSON data
 */
+ (NSData *)chx_dataWithPropertyList:(id)plist;



@end

@interface NSData (CHXEncoding)

/**
 *  Generate UTF-8 string from data
 *
 *  @return UTF-8 string
 */
- (NSString *)chx_UTF8String;

/**
 *  Generate ASCII string form data
 *
 *  @return ASCII string
 */
- (NSString *)chx_ASCIIString;

/**
 *  Generate ISOLatin1 string form data
 *
 *  @return ISOLatin1 string
 */
- (NSString *)chx_ISOLatin1String;

@end
