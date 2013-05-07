//
//  TKZConfigurationController.h
//  maiccu
//
//  Created by Kristof Hannemann on 05.05.13.
//  Copyright (c) 2013 Kristof Hannemann. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@interface TKZConfigurationController : NSObject <NSWindowDelegate> {
@private
    IBOutlet NSPopUpButton *tunnelChoise;
    
    IBOutlet NSProgressIndicator *usernameProgress;
    IBOutlet NSProgressIndicator *passwordProgress;
    
    IBOutlet NSView *usernameCheck;
    IBOutlet NSView *passwordCheck;
    
    
    IBOutlet NSTextField *usernameField;
    IBOutlet NSTextField *passwordField;
    
    IBOutlet NSButton *saveButton;
    IBOutlet NSButton *infoButton;
    
    IBOutlet NSTextField *infoField;
    IBOutlet NSTextField *headField;
        
    
}
@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSPopover *popover;

- (IBAction)clickLogin:(id)sender;
- (IBAction)clickSave:(id)sender;
- (IBAction)clickShowInfo:(id)sender;



@end
