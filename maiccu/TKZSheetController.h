//
//  TKZSheetController.h
//  maiccu
//
//  Created by Kristof Hannemann on 17.05.13.
//  Copyright (c) 2013 Kristof Hannemann. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TKZSheetController : NSWindowController

@property (weak) IBOutlet NSProgressIndicator *progressIndicator;
@property (weak) IBOutlet NSTextField *statusLabel;
@property (weak) IBOutlet NSButton *cancelButton;

@end
