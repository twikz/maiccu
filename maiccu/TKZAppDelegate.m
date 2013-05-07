//
//  TKZAppDelegate.m
//  maiccu
//
//  Created by Kristof Hannemann on 04.05.13.
//  Copyright (c) 2013 Kristof Hannemann. All rights reserved.
//

#import "TKZAppDelegate.h"
#import "TKZAiccuAdapter.h"

@implementation TKZAppDelegate

@synthesize window=_window;
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    TKZAiccuAdapter *aiccu = [[TKZAiccuAdapter alloc] init];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    //clean pid file
    [fileManager removeItemAtPath:[aiccu aiccuDefaultPidFilePath] error:nil];
        
}
- (void)awakeFromNib {
    TKZAiccuAdapter *aiccu = [[TKZAiccuAdapter alloc] init];
    if (![aiccu aiccuDefaultConfigExists]) {
        [_window makeKeyAndOrderFront:nil];
    }
}


@end
