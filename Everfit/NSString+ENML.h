//
//  NSString+ENML.h
//  Everfit
//
//  Created by Chris Salvato on 8/30/12.
//  Copyright (c) 2012 Swift Archer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (ENML)
+(NSString *)encapulateStringInENML:(NSString *)string;
+(NSString *)convertENMLToTextViewFormat:(NSString *)string;
@end
