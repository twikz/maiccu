//
//  TKZAppDelegate.m
//  maiccu
//
//  Created by Kristof Hannemann on 04.05.13.
//  Copyright (c) 2013 Kristof Hannemann. All rights reserved.
//

#import "TKZAppDelegate.h"
#import "TKZAiccuAdapter.h"
#import "TKZDetailsController.h"

@interface TKZAppDelegate () {
    NSStatusItem *_statusItem;
    TKZAiccuAdapter *_aiccu;
    TKZDetailsController *_detailsController;
}

@end

@implementation TKZAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    /*TKZAiccuAdapter *aiccu = [[TKZAiccuAdapter alloc] init];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    //just in case remove the pid files 
    [fileManager removeItemAtPath:[aiccu aiccuDefaultPidFilePath] error:nil];*/
    NSLog(@"applicationDidFinishLaunching");

}

- (id)init
{
    self = [super init];
    if (self) {
        //NSLog(@"Init");
        _aiccu = [[TKZAiccuAdapter alloc] init];
        _detailsController = [[TKZDetailsController alloc] init];
        
        [_detailsController setAiccu:_aiccu];
    }
    return self;
}

- (void)awakeFromNib {
    /*TKZAiccuAdapter *aiccu = [[TKZAiccuAdapter alloc] init];
    if (![aiccu aiccuDefaultConfigExists]) {
        [_window makeKeyAndOrderFront:nil];
    }*/
    _statusItem =[[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [_statusItem setMenu:_menu];
    [_statusItem setTitle:@"Maiccu"];
    [_statusItem setHighlightMode:YES];
    NSLog(@"awakeFromNib");
}


- (IBAction)clickedDetails:(id)sender {
    [_detailsController showWindow:sender];
    [NSApp activateIgnoringOtherApps:YES];
}

- (IBAction)clickedQuit:(id)sender {
    [[NSApplication sharedApplication] terminate:sender];
}
@end
