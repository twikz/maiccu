//
//  TKZDetailsController.h
//  maiccu
//
//  Created by Kristof Hannemann on 17.05.13.
//  Copyright (c) 2013 Kristof Hannemann. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TKZAiccuAdapter;

@interface TKZDetailsController : NSWindowController <NSTextFieldDelegate, NSPopoverDelegate, NSWindowDelegate>

@property (strong) TKZAiccuAdapter *aiccu;


//views
@property (strong) IBOutlet NSView *accountView;
@property (strong) IBOutlet NSView *setupView;
@property (strong) IBOutlet NSView *logView;


//toolbar
@property (weak) IBOutlet NSToolbar *toolbar;
@property (weak) IBOutlet NSToolbarItem *accountItem;
@property (weak) IBOutlet NSToolbarItem *setupItem;
@property (weak) IBOutlet NSToolbarItem *logItem;

- (IBAction)toolbarWasClicked:(id)sender;


//account view
@property (weak) IBOutlet NSTextField *usernameField;
@property (weak) IBOutlet NSSecureTextField *passwordField;
@property (weak) IBOutlet NSTextField *signupLabel;
@property (weak) IBOutlet NSImageView *usernameMarker;
@property (weak) IBOutlet NSImageView *passwordMarker;


//setup view
@property (weak) IBOutlet NSPopUpButton *tunnelPopUp;
@property (weak) IBOutlet NSButton *infoButton;
@property (weak) IBOutlet NSButton *natDetectButton;
@property (weak) IBOutlet NSButton *natCheckBox;

@property (weak) IBOutlet NSTextField *tunnelHeadField;
@property (weak) IBOutlet NSTextField *tunnelInfoField;
@property (strong) IBOutlet NSPopover *tunnelPopOver;



@property (unsafe_unretained) IBOutlet NSTextView *logTextView;
- (IBAction)clearWasClicked:(id)sender;
- (IBAction)reloadWasClicked:(id)sender;



- (IBAction)infoWasClicked:(id)sender;
- (IBAction)tunnelPopUpHasChanged:(id)sender;
- (IBAction)natCheckBoxDidChange:(id)sender;
- (IBAction)autoDetectWasClicked:(id)sender;


@end
