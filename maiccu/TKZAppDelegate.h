//
//  TKZAppDelegate.h
//  maiccu
//
//  Created by Kristof Hannemann on 04.05.13.
//  Copyright (c) 2013 Kristof Hannemann. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TKZAppDelegate : NSObject <NSApplicationDelegate> {

    
}

@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSMenu *menu;
@property (weak) IBOutlet NSMenuItem *startstopItem;

- (IBAction)clickedDetails:(id)sender;
- (IBAction)clickedQuit:(id)sender;
- (IBAction)startstopWasClicked:(id)sender;

@end
