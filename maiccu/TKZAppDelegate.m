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
    TKZDetailsController *_detailsController;
    BOOL _isAiccuRunning;
    NSURL *_logURL;
}

@end

@implementation TKZAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    //
    NSFileManager *fileManager = [NSFileManager defaultManager];

    NSURL *url = [[fileManager URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask] lastObject];
    _logURL = [url URLByAppendingPathComponent:@"Logs/Maiccu.log"];
    
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
    
    [self writeLogMessage:@"Maiccu did finish launching"];
}

- (void)writeLogMessage:(NSString *)logMessage {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:[_logURL path]] ) {
        [fileManager createFileAtPath:[_logURL path] contents:[NSData data] attributes:nil];
    }
    
    NSFileHandle *logFileHandle = [NSFileHandle fileHandleForWritingAtPath:[_logURL path]];
    [logFileHandle seekToFileOffset:[logFileHandle seekToEndOfFile]];
    NSString *timeStamp = [[NSDate date] descriptionWithLocale:[NSLocale systemLocale]];
    
    NSArray *messages = [logMessage componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\n\r"]];
    for (NSString *message in messages) {
        if (![message isEqualToString:@""]) {
            NSString *formatedMessage = [NSString stringWithFormat:@"[%@] %@\n", timeStamp, message];
            [logFileHandle writeData:[formatedMessage dataUsingEncoding:NSUTF8StringEncoding]];
        }
    }
    
    [logFileHandle closeFile];
}

- (void)applicationWillTerminate:(NSNotification *)notification {
    [self writeLogMessage:@"Maiccu will terminate"];
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
        
    }
    return self;
}

- (void)aiccuDidTerminate:(NSNotification *)aNotification {
    [self writeLogMessage:[NSString stringWithFormat:@"aiccu terminated with status %li", [[aNotification object] integerValue]]];
    [self postNotification:[NSString stringWithFormat:@"aiccu terminated with status %li", [[aNotification object] integerValue]]];
    _isAiccuRunning = NO;
    [_startstopItem setTitle:@"Start aiccu"];
}

- (void)aiccuNotification:(NSNotification *)aNotification {
    [self writeLogMessage:[aNotification object]];
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
    [_aiccu startStopAiccu];
}
@end
