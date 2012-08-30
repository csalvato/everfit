//
//  NSString+ENML.m
//  Everfit
//
//  Created by Chris Salvato on 8/30/12.
//  Copyright (c) 2012 Swift Archer. All rights reserved.
//

#import "NSString+ENML.h"

@implementation NSString (ENML)

#pragma mark - Text View Format to ENML
-(NSString *)convertTextViewFormatToENML {
    NSString *addedBRs = [self convertDoubleNewLinesToBR];
    NSString *addedDivs = [addedBRs convertNewLinesToDivs];
    return [addedDivs encapulateStringInENML];
}

-(NSString *)convertDoubleNewLinesToBR {
    NSError *error = NULL;
    NSRegularExpression *regex = 
    [NSRegularExpression regularExpressionWithPattern:@"\n(\n)" options:0 error:&error];
    
    NSArray *matches = [regex matchesInString:self
                                      options:0
                                        range:NSMakeRange(0, [self length])
                        ];
    
    NSString *outputString = self;
    matches = [[matches reverseObjectEnumerator] allObjects];
    for (NSTextCheckingResult *match in matches) {
        NSRange matchRange = [match rangeAtIndex:1];
        outputString = [outputString stringByReplacingCharactersInRange:matchRange withString:@"<br clear=\"none\"/>\n"];
    }
    
    return outputString;
}

-(NSString *)convertNewLinesToDivs {
    NSError *error = NULL;
    NSRegularExpression *regex = 
    [NSRegularExpression regularExpressionWithPattern:@"()(.+)(\n|$)" options:0 error:&error];
    
    NSArray *matches = [regex matchesInString:self
                                      options:0
                                        range:NSMakeRange(0, [self length])
                        ];
    
    NSString *outputString = self;
    matches = [[matches reverseObjectEnumerator] allObjects];
    for (NSTextCheckingResult *match in matches) {
        NSRange matchRange = [match rangeAtIndex:3];
        NSString *matchString = [self substringWithRange:matchRange];
        outputString = [outputString stringByReplacingCharactersInRange:matchRange withString:[@"</div>" stringByAppendingString:matchString]];
        
        
        matchRange = [match rangeAtIndex:1];
        matchString = [self substringWithRange:matchRange];
        outputString = [outputString stringByReplacingCharactersInRange:matchRange withString:[matchString stringByAppendingString:@"<div>"]];
    }
    
    return outputString;
}

-(NSString *)encapulateStringInENML {
    return [NSString stringWithFormat: @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<!DOCTYPE en-note SYSTEM \"http://xml.evernote.com/pub/enml2.dtd\">\n<en-note>%@</en-note>", self];
}

#pragma mark - ENML to Text View Format

-(NSString *)convertENMLToTextViewFormat {
    NSString *strippedENTags = [self stripENNoteTags];
    NSString *strippedDivs = [strippedENTags convertDivTagsToNewLines];
    return [strippedDivs convertBRTagsToNewLines];
}

-(NSString *) convertDivTagsToNewLines {
    NSError *error = NULL;
    NSRegularExpression *regex = 
    [NSRegularExpression regularExpressionWithPattern:@"<div>(.+)</div>" options:0 error:&error];
    
    NSArray *matches = [regex matchesInString:self
                                      options:0
                                        range:NSMakeRange(0, [self length])
                        ];
    
    NSString *outputString = @"";
    for (NSTextCheckingResult *match in matches) {
        NSRange matchRange = [match rangeAtIndex:1];
        NSString *matchString = [self substringWithRange:matchRange];
        outputString = [NSString stringWithFormat:@"%@%@\n", outputString,matchString];
    }
    
    return outputString;
}

-(NSString *) convertBRTagsToNewLines {
    NSError *error = NULL;
    NSRegularExpression *regex = 
    [NSRegularExpression regularExpressionWithPattern:@"<br(.+)/>" options:0 error:&error];
    
    NSArray *matches = [regex matchesInString:self
                                      options:0
                                        range:NSMakeRange(0, [self length])
                        ];
    
    NSString *outputString = self;
    for (NSTextCheckingResult *match in matches) {
        NSRange matchRange = [match range];
        outputString = [outputString stringByReplacingCharactersInRange:matchRange withString:@""];
    }
    
    return outputString;
}


-(NSString *)stripENNoteTags{
    NSError *error = NULL;
    NSRegularExpression *regex = 
    [NSRegularExpression regularExpressionWithPattern:@"<en-note>((.|\n)+)</en-note>" options:0 error:&error];
    
    NSArray *matches = [regex matchesInString:self
                                      options:0
                                        range:NSMakeRange(0, [self length])
                        ];
    
    NSString *matchString;
    for (NSTextCheckingResult *match in matches) {
        NSRange matchRange = [match rangeAtIndex:1];
        matchString = [self substringWithRange:matchRange];
    }
    
    return matchString;
}



@end