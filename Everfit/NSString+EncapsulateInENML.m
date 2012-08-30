//
//  NSString+EncapsulateInENML.m
//  Everfit
//
//  Created by Chris Salvato on 8/30/12.
//  Copyright (c) 2012 Swift Archer. All rights reserved.
//

#import "NSString+EncapsulateInENML.h"

@implementation NSString (EncapsulateInENML)

+(NSString *)encapulateStringInENML:(NSString *)string {
    return [NSString stringWithFormat: @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<!DOCTYPE en-note SYSTEM \"http://xml.evernote.com/pub/enml2.dtd\">\n<en-note>%@</en-note>", string];
}

@end
