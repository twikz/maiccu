//
//  TKZMaiccu.m
//  maiccu
//
//  Created by Kristof Hannemann on 20.05.13.
//  Copyright (c) 2013 Kristof Hannemann. All rights reserved.
//

#import "TKZMaiccu.h"

static TKZMaiccu *defaultMaiccu = nil;

@interface TKZMaiccu () {
    NSFileManager *_fileManager;
}

@end

@implementation TKZMaiccu


- (id)init
{
    self = [super init];
    if (self) {
        _fileManager = [NSFileManager defaultManager];
    }
    return self;
}

+ (id) defaultMaiccu {
    if (!defaultMaiccu) {
        defaultMaiccu = [[TKZMaiccu alloc] init];
    }
    return defaultMaiccu;
}


- (NSURL *) appSupportURL {
    NSURL *appSupportURL = [[_fileManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
    return [appSupportURL URLByAppendingPathComponent:@"Maiccu"];
}

- (NSString *)aiccuPath {
    return [[NSBundle mainBundle] pathForResource:@"aiccu" ofType:@""];
}


- (NSString *)aiccuLogFilePath {
    return [[[self appSupportURL] URLByAppendingPathComponent:@"aiccu.log"] path];
}

- (BOOL) aiccuLogFileExists {
    return [_fileManager fileExistsAtPath:[self aiccuLogFilePath]];
}


- (BOOL) aiccuConfigExists {    
    return [_fileManager fileExistsAtPath:[self aiccuConfigPath]];
}

- (NSString *) aiccuConfigPath {
    return [[[self appSupportURL] URLByAppendingPathComponent:@"aiccu.conf"] path];
}

@end
