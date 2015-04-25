//
//  NSObject+ObjcRuntime.m
//  NWNetworkingWrapper
//
//  Created by Moch Xiao on 4/25/15.
//  Copyright (c) 2015 Moch Xiao. All rights reserved.
//

#import "NSObject+ObjcRuntime.h"
#import <objc/runtime.h>

@implementation NSObject (ObjcRuntime)

- (NSArray *)objc_properties {
    NSMutableArray *propertyArray = [[NSMutableArray alloc] init];
    u_int count;
    objc_property_t *propertyList = class_copyPropertyList([self class], &count);
    for (int i = 0; i < count; i++) {
        const char *propertyName = property_getName(propertyList[i]);
        NSString *stringName = [NSString  stringWithCString:propertyName
                                                   encoding:NSUTF8StringEncoding];
        [propertyArray addObject:stringName];
    }
    
    free(propertyList);
    
    return [[NSArray alloc] initWithArray:propertyArray];
}

@end
