//
//  TKZDetailsController.m
//  maiccu
//
//  Created by Kristof Hannemann on 17.05.13.
//  Copyright (c) 2013 Kristof Hannemann. All rights reserved.
//

#import "TKZDetailsController.h"
#import "TKZAiccuAdapter.h"
#import "TKZSheetController.h"
#import "TKZMaiccu.h"


@interface TKZDetailsController () {
    NSMutableDictionary *_config;
    NSMutableArray *_tunnelInfoList;
    TKZMaiccu *_maiccu;
}
-(id)hyperlinkFromString:(NSString*)inString withURL:(NSURL*)aURL;

@end

@implementation TKZDetailsController

- (id)init
{
    self = [super initWithWindowNibName:@"TKZDetailsController"];
    if (self) {
        _config = [[NSMutableDictionary alloc] init];
        _tunnelInfoList = [[NSMutableArray alloc] init];
        _maiccu = [TKZMaiccu defaultMaiccu];
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
    
    if ([_config count]) {
        [NSThread detachNewThreadSelector:@selector(doLogin) toTarget:self withObject:nil];
    }
    
}

-(void)controlTextDidEndEditing:(NSNotification *)notification
{
    // See if it was due to a return
    if ( [[[notification userInfo] objectForKey:@"NSTextMovement"] intValue] == NSReturnTextMovement )
    {
        [NSThread detachNewThreadSelector:@selector(doLogin) toTarget:self withObject:nil];
    }
}

-(id)hyperlinkFromString:(NSString*)inString withURL:(NSURL*)aURL
{
    NSMutableAttributedString* attrString = [[NSMutableAttributedString alloc] initWithString: inString];
    NSRange range = NSMakeRange(0, [attrString length]);
    
    [attrString beginEditing];
    [attrString addAttribute:NSLinkAttributeName value:[aURL absoluteString] range:range];
    
    // make the text appear in blue
    [attrString addAttribute:NSForegroundColorAttributeName value:[NSColor blueColor] range:range];
    
    // next make the text appear with an underline
    [attrString addAttribute:
     NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:NSSingleUnderlineStyle] range:range];
    
    [attrString endEditing];
    
    return attrString;
}

- (void)awakeFromNib {
    
    [_toolbar setSelectedItemIdentifier:[_accountItem itemIdentifier]];
    [self toolbarWasClicked:_accountItem];
    
    [_signupLabel setAllowsEditingTextAttributes:YES];
    [_signupLabel setSelectable:YES];
    [_signupLabel setAttributedStringValue:[self hyperlinkFromString:@"No account yet? Signup on sixXS.net" withURL:[NSURL URLWithString:@"http://www.sixxs.net"]]];
    
    
    NSDictionary *config = [_aiccu loadAiccuConfigFile:[_maiccu aiccuConfigPath]];
    //config = nil;
    if (config) {
        [_usernameField setStringValue:[config objectForKey:@"username"]];
        [_passwordField setStringValue:[config objectForKey:@"password"]];
        [_natCheckBox setState:[[config objectForKey:@"behindnat"] integerValue]];

        [_config setDictionary:config];
    }
    else {
        [[self window] makeFirstResponder:_usernameField];
    }
    
    
    [[_logTextView textContainer] setContainerSize:NSMakeSize(FLT_MAX, FLT_MAX)];
    [[_logTextView textContainer] setWidthTracksTextView:NO];
    [_logTextView setHorizontallyResizable:YES];
    
    
    NSString *log = [NSString stringWithContentsOfFile:[_maiccu maiccuLogPath] encoding:NSUTF8StringEncoding error:nil];
    
    if (log) {
        [_logTextView setString:log];
    }
}

- (void)doLogin {
    TKZSheetController *sheet  = [[TKZSheetController alloc] init];
    NSInteger errorCode = 0;
    
    [NSApp beginSheet:[sheet window] modalForWindow:[self window] modalDelegate:nil didEndSelector:nil contextInfo:nil];
    
    [[sheet window] makeKeyAndOrderFront:nil];
    [[sheet window] display];
    
    [[sheet statusLabel] setTextColor:[NSColor blackColor]];
    [[sheet progressIndicator] setIndeterminate:NO];
    
    [[sheet statusLabel] setStringValue:@"Connecting to tic server..."];
    [[sheet progressIndicator] setDoubleValue:25.0f];
    [NSThread sleepForTimeInterval:0.5f];
    
    errorCode = [_aiccu loginToTicServer:@"tic.sixxs.net" withUsername:[_usernameField stringValue] andPassword:[_passwordField stringValue]];
    
    [_tunnelPopUp removeAllItems];
    [_tunnelInfoList removeAllObjects];
    
    
    if (!errorCode) {
        
        [[sheet statusLabel] setStringValue:@"Retrieving tunnel list..."];
        [[sheet progressIndicator] setDoubleValue:50.0f];
        [NSThread sleepForTimeInterval:0.5f];
        
        NSArray *tunnelList = [_aiccu requestTunnelList];
        
        double progressInc = 40.0f / [tunnelList count];
        
        
        NSUInteger tunnelSelectIndex = 0;
        for (NSDictionary *tunnel in tunnelList)
        {
            //the behavior of "userstate: disabled" and "adminstate: requested" is not implemented yet
            
            [[sheet statusLabel] setStringValue:@"Fetching tunnel info..."];
            [[sheet progressIndicator] incrementBy:progressInc];
            [NSThread sleepForTimeInterval:0.5f];
            
            [_tunnelInfoList addObject:[_aiccu requestTunnelInfoForTunnel:[tunnel objectForKey:@"id"]]];
            
            [_tunnelPopUp addItemWithTitle:[NSString stringWithFormat:@"-- %@ --", [tunnel objectForKey:@"id"]]];
            
            if ([[_config objectForKey:@"tunnel_id"] isEqualToString:[tunnel objectForKey:@"id"]]) {
                tunnelSelectIndex = [_tunnelInfoList count] - 1;
                //tunnelid = [tunnel objectForKey:@"id"];
            }
        }
        
        //[_natCheckBox setState:[]]
        
        [_config removeAllObjects];
        [_config setObject:[NSNumber numberWithInteger:[_natCheckBox state]] forKey:@"behindnat"];
        [_config setObject:[_usernameField stringValue] forKey:@"username"];
        [_config setObject:[_passwordField stringValue] forKey:@"password"];
        
        if ([tunnelList count]) {
            [_tunnelPopUp setEnabled:YES];
            [_infoButton setEnabled:YES];
            [_natCheckBox setEnabled:YES];
            [_natDetectButton setEnabled:YES];
            
            [_config setObject:[[_tunnelInfoList objectAtIndex:tunnelSelectIndex] objectForKey:@"id"] forKey:@"tunnel_id"];
            [_tunnelPopUp selectItemAtIndex:tunnelSelectIndex];
            
            //refesh popover menu
            [self tunnelPopUpHasChanged:nil];
            
        }
        else {
            [_tunnelPopUp addItemWithTitle:@"--no tunnels--"];
            [_tunnelPopUp setEnabled:NO];
            [_infoButton setEnabled:NO];
            [_natCheckBox setEnabled:NO];
            [_natDetectButton setEnabled:NO];
            
        }
        
        
        [[sheet statusLabel] setStringValue:@"Successfully completed."];
        [[sheet progressIndicator] incrementBy:100.0f];
        [NSThread sleepForTimeInterval:0.5f];
        
        [_usernameMarker setHidden:YES];
        [_passwordMarker setHidden:YES];
        
        
    }
    //if something went wrong
    else {
        [_config removeAllObjects];
        
        [[sheet statusLabel] setStringValue:@"Invalid login credentials"];
        [[sheet statusLabel] setTextColor:[NSColor redColor]];
        [[sheet progressIndicator] setIndeterminate:YES];
        [NSThread sleepForTimeInterval:2.0f];
        
               
        [_passwordField becomeFirstResponder]; 
        
        [_tunnelPopUp setEnabled:NO];
        [_infoButton setEnabled:NO];
        [_natCheckBox setEnabled:NO];
        [_natDetectButton setEnabled:NO];
        [_usernameMarker setHidden:NO];
        [_passwordMarker setHidden:NO];
        
    }
    
    
    [_aiccu logoutFromTicServerWithMessage:@"Bye Bye"];
    
    [NSApp endSheet:[sheet window]];
    [[sheet window] orderOut:nil];
    
    
    if (!errorCode) {
        [NSThread sleepForTimeInterval:0.1f];
        [_toolbar setSelectedItemIdentifier:[_setupItem itemIdentifier]];
        [self toolbarWasClicked:_setupItem];
    }
}


- (void)doNATDetection {
    
    TKZSheetController *sheet = [[TKZSheetController alloc] init];
    
    [NSApp beginSheet:[sheet window] modalForWindow:[self window] modalDelegate:nil didEndSelector:nil contextInfo:nil];
    
    [[sheet window] makeKeyAndOrderFront:nil];
    [[sheet window] display];
    
    [[sheet statusLabel] setTextColor:[NSColor blackColor]];
    [[sheet progressIndicator] setIndeterminate:YES];
    
    [[sheet statusLabel] setStringValue:@"Fetching external ip address"];
    [NSThread sleepForTimeInterval:0.5f];
    
    NSError *error = nil;
    NSString *extAddress = [NSString stringWithContentsOfURL:[NSURL URLWithString:@"http://ipecho.net/plain"] encoding:NSASCIIStringEncoding error:&error];
    
    if (!error) {
        
        [_natCheckBox setState:1];
        for (NSString *address in [[NSHost currentHost] addresses]) {
            if ([extAddress isEqualToString:address]) {
                //
                [_natCheckBox setState:0];
                break;
            }
        }
        [[sheet statusLabel] setStringValue:@"Successfully completed"];
        [NSThread sleepForTimeInterval:0.5f];
    }
    else {
        [[sheet statusLabel] setTextColor:[NSColor redColor]];
        [[sheet statusLabel] setStringValue:@"Error fetching external ip address"];
        [NSThread sleepForTimeInterval:2.0f];
    }
    

    [NSApp endSheet:[sheet window]];
    [[sheet window] orderOut:nil];
    
    [self syncConfig];
}

- (IBAction)toolbarWasClicked:(id)sender {
    NSWindow *window = [self window];
    NSView *newView = nil;

    if ([sender isEqual:_accountItem]) {
        newView = _accountView;
    }
    else if ([sender isEqual:_setupItem]) {
        newView = _setupView;
    }
    else if ([sender isEqual:_logItem]) {
        newView = _logView;
    }
    else {
        NSLog(@"Unexpected toolbar click.");
        return;
    }
    
    NSSize currentSize = [[window contentView] frame].size;
    NSSize newSize = [newView frame].size;
	
	float deltaWidth = newSize.width - currentSize.width;
    float deltaHeight = newSize.height - currentSize.height;
    
    NSRect windowFrame = [window frame];  
    
    windowFrame.size.height += deltaHeight;
    windowFrame.origin.y -= deltaHeight;
    windowFrame.size.width += deltaWidth;
    // Clear the box for resizing
    [window setContentView:[[NSView alloc] initWithFrame:NSMakeRect(0, 0, 500, 500)]];
    [window  setFrame:windowFrame
               display:YES
               animate:YES];
    [window setContentView:newView];
}

- (IBAction)clearWasClicked:(id)sender {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    [fileManager removeItemAtPath:[_maiccu maiccuLogPath] error:nil];
    [fileManager createFileAtPath:[_maiccu maiccuLogPath] contents:[NSData data] attributes:nil];
    [self reloadWasClicked:sender];
}

- (IBAction)reloadWasClicked:(id)sender {
    [_logTextView setString:[NSString stringWithContentsOfFile:[_maiccu maiccuLogPath] encoding:NSUTF8StringEncoding error:nil]];
}

- (IBAction)infoWasClicked:(id)sender {
    if ([sender state]) {
        [_tunnelPopOver showRelativeToRect:[sender bounds] ofView:sender preferredEdge:NSMaxYEdge];
    }
    else {
        [_tunnelPopOver close];
    }
}

- (void)windowWillClose:(NSNotification *)notification {
    [self syncConfig];
}


- (void)syncConfig {
    if ([_config count]) {
        NSLog(@"saving aiccu config");
        [_aiccu saveAiccuConfig:_config toFile:[_maiccu aiccuConfigPath]];
    }
    else {
        NSLog(@"deleting aiccu config");
        [[NSFileManager defaultManager] removeItemAtPath:[_maiccu aiccuConfigPath] error:nil];
    }
}

- (void)popoverWillClose:(NSNotification *)notification {
    [_infoButton setState:0];
}

- (IBAction)tunnelPopUpHasChanged:(id)sender {
    //
    NSDictionary *tunnelInfo = [_tunnelInfoList objectAtIndex:[_tunnelPopUp indexOfSelectedItem]];
    
    //set current tunnel id
    [_config setObject:[tunnelInfo objectForKey:@"id"] forKey:@"tunnel_id"];
    
    //set text in popup view
    [_tunnelHeadField setStringValue:[NSString stringWithFormat:@"Tunnel %@", [tunnelInfo objectForKey:@"id"]]];
    [_tunnelInfoField setStringValue:[NSString stringWithFormat:
                               @"Popid     : %@\n"
                               @"Type      : %@\n\n"
                               @"IPv4 local: %@\n"
                               @"IPv4 pop  : %@\n\n"
                               @"IPv6 local: %@/%@\n"
                               @"IPv6 pop  : %@/%@\n\n"
                               @"MTU       : %@"
                               ,
                               [tunnelInfo objectForKey:@"pop_id"],
                               [tunnelInfo objectForKey:@"type"],
                               [tunnelInfo objectForKey:@"ipv4_local"],
                               [tunnelInfo objectForKey:@"ipv4_pop"],
                               [tunnelInfo objectForKey:@"ipv6_local"], [[tunnelInfo objectForKey:@"ipv6_prefixlength"] stringValue],
                               [tunnelInfo objectForKey:@"ipv6_pop"], [[tunnelInfo objectForKey:@"ipv6_prefixlength"] stringValue],
                               [[tunnelInfo objectForKey:@"mtu"] stringValue]
                               ]];
    [self syncConfig];
}

- (IBAction)natCheckBoxDidChange:(id)sender {
    if ([_natCheckBox state]) {
        [_config setObject:[NSNumber numberWithInteger:1] forKey:@"behindnat"];
    }
    else {
        [_config setObject:[NSNumber numberWithInteger:0] forKey:@"behindnat"];
    }
    [self syncConfig];
}

- (IBAction)autoDetectWasClicked:(id)sender {
    [NSThread detachNewThreadSelector:@selector(doNATDetection) toTarget:self withObject:nil];
}
@end
