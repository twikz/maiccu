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
#import "TKZMaiccu.h"
#import <Growl/Growl.h>

@interface TKZAppDelegate () {
    NSStatusItem *_statusItem;
    TKZAiccuAdapter *_aiccu;
    TKZMaiccu *_maiccu;
    TKZDetailsController *_detailsController;
    BOOL _isAiccuRunning;
}

@end

@implementation TKZAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    //
    
    /*NSDictionary *dict = [fileManager attributesOfItemAtPath:@"/Users/kristof/Downloads/testomat/aiccu" error:nil];
    for (id key in dict) {
        NSLog(@"%@ -> %@", key, [dict objectForKey:key]);
    }
    NSLog(@"%lo",[[dict objectForKey:NSFilePosixPermissions] integerValue]);
    NSLog(@"%@",[[dict objectForKey:NSFilePosixPermissions] className]);
    NSLog(@"%@",[NSFilePosixPermissions className]);
    NSLog(@"%@",[[NSString string] className]);*/
    
    /*if (![fileManager fileExistsAtPath:[_logURL path]] ) {
        [fileManager createFileAtPath:[_logURL path] contents:[NSData data] attributes:nil];
    }
    
    _logFileHandle = [NSFileHandle fileHandleForWritingAtPath:[_logURL path]];
    [_logFileHandle seekToFileOffset:[_logFileHandle seekToEndOfFile]];*/
    
    //[_logFileHandle writeData:[@"Es geht los" dataUsingEncoding:NSUTF8StringEncoding]];
    
    [_maiccu writeLogMessage:@"Maiccu did finish launching"];
}


- (void)applicationWillTerminate:(NSNotification *)notification {
    [_maiccu writeLogMessage:@"Maiccu will terminate"];
}

- (id)init
{
    self = [super init];
    if (self) {
        //NSLog(@"Init");
        _aiccu = [[TKZAiccuAdapter alloc] init];
        _detailsController = [[TKZDetailsController alloc] init];
        
        [_detailsController setAiccu:_aiccu];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(aiccuDidTerminate:) name:TKZAiccuDidTerminate object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(aiccuNotification:) name:TKZAiccuStatus object:nil];
        
        _isAiccuRunning = NO;
        
        _maiccu = [TKZMaiccu defaultMaiccu];
        
    }
    return self;
}

- (void)aiccuDidTerminate:(NSNotification *)aNotification {
    [_maiccu writeLogMessage:[NSString stringWithFormat:@"aiccu terminated with status %li", [[aNotification object] integerValue]]];
    [self postNotification:[NSString stringWithFormat:@"aiccu terminated with status %li", [[aNotification object] integerValue]]];
    _isAiccuRunning = NO;
    [_startstopItem setTitle:@"Start aiccu"];
}

- (void)aiccuNotification:(NSNotification *)aNotification {
    [_maiccu writeLogMessage:[aNotification object]];
    [self postNotification:[aNotification object]];
}

- (void)postNotification:(NSString *) message{
    NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
    [GrowlApplicationBridge notifyWithTitle:appName
                                description:message
                           notificationName:@"status"
                                   iconData:nil
                                   priority:0
                                   isSticky:NO
                               clickContext:nil];
}

- (void)awakeFromNib {
    _statusItem =[[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [_statusItem setMenu:_menu];
    [_statusItem setTitle:@"IPv6"];
    [_statusItem setHighlightMode:YES];
}


- (IBAction)clickedDetails:(id)sender {
    [_detailsController showWindow:sender];
    [NSApp activateIgnoringOtherApps:YES];
}

- (IBAction)clickedQuit:(id)sender {
    [[NSApplication sharedApplication] terminate:sender];
}

- (IBAction)startstopWasClicked:(id)sender {
    _isAiccuRunning = YES;
    [_startstopItem setTitle:@"Stop aiccu"];
    [_aiccu startStopAiccuFrom:@"/Users/kristof/Downloads/testomat/aiccu"];
}
@end
