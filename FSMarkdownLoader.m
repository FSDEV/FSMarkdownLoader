//
//  FSMarkdownLoader.m
//  FSMarkdownLoader
//
//  Created by Christopher Miller on 6/27/11.
//  Copyright 2011 FSDEV. All rights reserved.
//

#import "FSMarkdownLoader.h"

static BOOL _isBooleanTrue(NSString *aString);
static BOOL _isBooleanFalse(NSString *aString);

@implementation FSMarkdownLoader

+ (NSDictionary *)dictionaryFromString:(NSString *)markdown
{
    FSMarkdownLoader * ml = [[FSMarkdownLoader alloc] initWithString:markdown];
    NSDictionary * d = [ml scan];
    [ml release];
    return d;
}

- (id)initWithString:(NSString *)markdown
{
    self = [self init];
    if (self) {
        md = [markdown retain];
    }
    return self;
}

/// THIS WHOLE FUNCTION IS TAKE FROM YAMLKIT
/// https://github.com/patrickt/yamlkit/blob/master/src/YKParser.m
/// at the time this code was pilfered, YAMLKIT was MIT-licensed.
- (id)_interpretObjectFromString:(NSString *)stringValue
{
	id obj = stringValue;
    
	NSScanner *scanner = [NSScanner scannerWithString:obj];
        
    // Integers are automatically casted unless given a !!str tag. I think.
    if([scanner scanDouble:NULL] && [scanner scanLocation] == [stringValue length]) {
        obj = [NSNumber numberWithDouble:[obj doubleValue]];
    } else if([scanner scanInteger:NULL] && [scanner scanLocation] == [stringValue length]) {
        obj = [NSNumber numberWithInteger:[obj integerValue]];
        // FIXME: Boolean parsing here is not in accordance with the YAML standards.
    } else if(_isBooleanTrue((NSString *)obj))     {
        obj = [NSNumber numberWithBool:YES];
    } else if(_isBooleanFalse((NSString *)obj))    {
        obj = [NSNumber numberWithBool:NO];
    } else if([obj isEqualToString:@"~"]) {
        obj = [NSNull null];
    }

	return obj;
}


- (NSMutableDictionary *)scanWithLines:(NSMutableArray *)lines
                             hashLevel:(NSUInteger)level
{
    NSMutableDictionary * d = [NSMutableDictionary dictionary];
    
    NSString * line;
    while ([lines count] > 0) {
        line = [lines objectAtIndex:0];
        
        if ([line isMatchedByRegex:@"^\\#+"]) {
            NSArray * arr = [[line arrayOfCaptureComponentsMatchedByRegex:@"^(\\#+)\\ ?(.*)"] objectAtIndex:0];
            if ([[arr objectAtIndex:1] length] <= level)
                return d;
            else
                [lines removeObjectAtIndex:0];
            
            [d setValue:[self scanWithLines:lines
                                  hashLevel:[[arr objectAtIndex:1] length]]
                 forKey:[arr objectAtIndex:2]];
        } else {
        
            [lines removeObjectAtIndex:0];
            
            if ([line isMatchedByRegex:@"^\\*\\*(.+)\\*\\*\\:\\ ?(.*)"]) {
                NSArray * matches = [[line arrayOfCaptureComponentsMatchedByRegex:@"^\\*\\*(.+)\\*\\*\\:\\ ?(.*)"] objectAtIndex:0];
                NSString * key = [matches objectAtIndex:1];
                NSArray * values = [[matches objectAtIndex:2] arrayOfCaptureComponentsMatchedByRegex:@"(\\`([^\\`]+)\\`)"];
                if ([values count] == 0)
                    continue; // it isn't a k/v pair
                NSMutableArray * realValues = [NSMutableArray arrayWithCapacity:[values count]];
                for (NSArray * brr in values)
                    [realValues addObject:[self _interpretObjectFromString:[brr lastObject]]];
                if ([realValues count] > 1) {
                    // hrm, gotta think
                    [d setValue:realValues
                         forKey:key];
                } else
                    [d setValue:[realValues lastObject]
                         forKey:key];
            }
            
        }
    }
    
    return d;
}

- (NSDictionary *)scan
{
    NSMutableArray * lines = [NSMutableArray arrayWithArray:[md componentsSeparatedByRegex:@"(\\n\\n|\\ \\ \\n)"]];
    
    [lines removeObject:@"  \n"];
    [lines removeObject:@"\n\n"];
    
    return [self scanWithLines:lines
                     hashLevel:0];
}

#pragma mark NSObject

- (id)init
{
    self = [super init];
    if (self) {
        md = nil;
    }
    
    return self;
}

- (void)dealloc
{
    if (md) [md release];
    [super dealloc];
}

@end

static BOOL _isBooleanFalse(NSString *aString)
{
    BOOL isFalse = NO;
    const char *cstr = [aString UTF8String];
    char *falseValues[] = {
        "false", "False", "FALSE",
        "n", "N", "NO", "No", "no",
        "off", "Off", "OFF"
    };
    size_t length = sizeof(falseValues) / sizeof(*falseValues);
    int index;
    for(index = 0; index < length && !isFalse; index++) {
        isFalse = strcmp(cstr, falseValues[index]) == 0;
    }
    return isFalse;
}
 
static BOOL _isBooleanTrue(NSString *aString)
{
    BOOL isTrue = NO;
    const char *cstr = [aString UTF8String];
    char *trueValues[] = {
        "true", "TRUE", "True",
        "y", "Y", "Yes", "yes", "YES",
        "on", "On", "ON"
    };
    size_t length = sizeof(trueValues) / sizeof(*trueValues);
    int index;
    for(index = 0; index < length && !isTrue; index++) {
        isTrue = strcmp(cstr, trueValues[index]) == 0;
    }
    return isTrue;
}
