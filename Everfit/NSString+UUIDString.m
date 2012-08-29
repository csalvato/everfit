//
//  NSString+UUIDString.m
//  Everfit
//
//  Created by Chris Salvato on 8/29/12.
//  Copyright (c) 2012 Swift Archer. All rights reserved.
//

#import "NSString+UUIDString.h"

@implementation NSString (UUIDString)

+ (NSString *)generateUUIDString
{
    // create a new UUID which you own
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    
    // create a new CFStringRef (toll-free bridged to NSString)
    // that you own
    NSString *uuidString = (__bridge NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuid);
    
    // release the UUID
    CFRelease(uuid);
    
    return uuidString;
}

@end
