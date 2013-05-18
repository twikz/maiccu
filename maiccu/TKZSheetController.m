//
//  TKZSheetController.m
//  maiccu
//
//  Created by Kristof Hannemann on 17.05.13.
//  Copyright (c) 2013 Kristof Hannemann. All rights reserved.
//

#import "TKZSheetController.h"

@interface TKZSheetController ()

@end

@implementation TKZSheetController

- (id)init
{
    self = [super initWithWindowNibName:@"TKZSheetController"];
    if (self) {
        //
    }
    return self;
}


- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}


- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

@end
