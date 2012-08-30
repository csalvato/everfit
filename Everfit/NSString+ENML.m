//
//  NSString+ENML.m
//  Everfit
//
//  Created by Chris Salvato on 8/30/12.
//  Copyright (c) 2012 Swift Archer. All rights reserved.
//

#import "NSString+ENML.h"

@implementation NSString (ENML)

+(NSString *)encapulateStringInENML:(NSString *)string {
    return [NSString stringWithFormat: @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<!DOCTYPE en-note SYSTEM \"http://xml.evernote.com/pub/enml2.dtd\">\n<en-note>%@</en-note>", string];
}

+(NSString *)convertENMLToTextViewFormat:(NSString *)string {
    NSError *error = NULL;
    NSRegularExpression *regex = 
    [NSRegularExpression regularExpressionWithPattern:@"<en-note>(.+)</en-note>" options:0 error:&error];
    
    NSArray *matches = [regex matchesInString:string
                                      options:0
                                        range:NSMakeRange(0, [string length])
                        ];
    
    NSString *matchString;
    for (NSTextCheckingResult *match in matches) {
        NSRange matchRange = [match rangeAtIndex:1];
        matchString = [string substringWithRange:matchRange];
        NSLog(@"%@", matchString);
    }
    
    return matchString;
}

@end