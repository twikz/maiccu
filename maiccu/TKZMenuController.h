//
//  TKZStatusBarController.h
//  maiccu
//
//  Created by Kristof Hannemann on 04.05.13.
//  Copyright (c) 2013 Kristof Hannemann. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface TKZMenuController : NSObject {
@private
    NSStatusItem *statusItem;
    IBOutlet NSMenu *menu;
    IBOutlet NSMenuItem *menuItemConnect;
    
}

@property (assign) IBOutlet NSWindow *window;

- (IBAction)menuQuit:(id)sender;
- (IBAction)menuConfigure:(id)sender;
- (IBAction)menuConnect:(id)sender;
@end

