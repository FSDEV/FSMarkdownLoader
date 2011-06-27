//
//  FSMarkdownLoader.h
//  FSMarkdownLoader
//
//  Created by Christopher Miller on 6/27/11.
//  Copyright 2011 FSDEV. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RegexKitLite.h"


@interface FSMarkdownLoader : NSObject {
@private
    NSString * md;
}

+ (NSDictionary *)dictionaryFromString:(NSString *)markdown;

- (id)initWithString:(NSString *)markdown;

- (NSDictionary *)scan;

@end
