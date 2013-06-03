//
//  TKZMaiccu.h
//  maiccu
//
//  Created by Kristof Hannemann on 20.05.13.
//  Copyright (c) 2013 Kristof Hannemann. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TKZMaiccu : NSObject 
- (NSString *) aiccuConfigPath;
- (BOOL) aiccuConfigExists;

- (NSString *)aiccuPath;

- (NSString *)maiccuLogPath;
- (BOOL) maiccuLogExists;

- (NSString *)launchAgentPlistPath;
- (BOOL)setToLaunchAgent:(BOOL)value;
- (BOOL)isLaunchAgent;

- (void)writeLogMessage:(NSString *)logMessage;

+ (id)defaultMaiccu;
@end
