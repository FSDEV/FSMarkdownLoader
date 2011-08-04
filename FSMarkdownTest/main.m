//
//  main.m
//  FSMarkdownTest
//
//  Created by Christopher Miller on 8/4/11.
//  Copyright 2011 FSDEV. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <stdio.h>

#import "FSMarkdownLoader.h"

int main (int argc, const char * argv[])
{

    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

    // insert code here...
    NSString * filename = [[[NSProcessInfo processInfo] arguments] lastObject];
    NSError * err = nil;
    NSString * filedata = [NSString stringWithContentsOfFile:filename
                                                    encoding:NSUTF8StringEncoding
                                                       error:&err];
    
    if (err) {
        printf("Error: %s\n", [[err description] UTF8String]);
        return -1;
    }
    
    if (filedata == nil) {
        printf("Error: Cannot open file!\n");
        return -2;
    }
    
    printf("%s\n", [[[FSMarkdownLoader dictionaryFromString:filedata] description] UTF8String]);

    [pool drain];
    return 0;
}

