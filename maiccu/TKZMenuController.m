//
//  TKZStatusBarController.m
//  maiccu
//
//  Created by Kristof Hannemann on 04.05.13.
//  Copyright (c) 2013 Kristof Hannemann. All rights reserved.
//

#import "TKZMenuController.h"
#import "TKZAiccuAdapter.h"



@interface TKZMenuController () {
@private
    TKZAiccuAdapter *aiccu;
}

@end

@implementation TKZMenuController
@synthesize window=_window;


- (IBAction)menuConnect:(id)sender {
    //connect
    if (![aiccu isRunnging]) {
        if (![aiccu startAiccu]) {
            NSLog(@"Unable to start aiccu.");
            return;
        }
        [menuItemConnect setTitle:@"Stop aiccu"];
    }
    else {
        [aiccu stopAiccu];
        [menuItemConnect setTitle:@"Start aiccu"];
    }
}


- (IBAction)menuConfigure:(id)sender {
    
    [_window makeKeyAndOrderFront:sender];

    
}

- (IBAction)menuQuit:(id)sender {
    if ([aiccu isRunnging]) {
        [aiccu stopAiccu];
    }
    
    [NSApp terminate:nil];
    
}

- (id)init
{
    if (self = [super init]) {
        aiccu = [[TKZAiccuAdapter alloc] init];
    }
    
    return self;
}

- (void) awakeFromNib {
    
    statusItem =[[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [statusItem setMenu:menu];
    [statusItem setTitle:@"Maiccu"];
    [statusItem setHighlightMode:YES];
    
    
}


@end
