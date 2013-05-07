//
//  TKZConfigurationController.m
//  maiccu
//
//  Created by Kristof Hannemann on 05.05.13.
//  Copyright (c) 2013 Kristof Hannemann. All rights reserved.
//

#import "TKZConfigurationController.h"
#import "TKZAiccuAdapter.h"

@interface TKZConfigurationController (){
@private
    BOOL isConcurrent;
    NSString *password;
    NSString *username;
    NSString *tunnelid;
    TKZAiccuAdapter *aiccu;
    NSMutableArray *tunnelInfoList;
    BOOL isOpenedFirstTime;
}
- (CAKeyframeAnimation *)shakeAnimation:(NSRect)frame;
- (void)doLogin;

@end

static int numberOfShakes = 10;
static float durationOfShake = 0.4f;
static float vigourOfShake = 0.05f;

@implementation TKZConfigurationController
@synthesize window=_window, popover=_popover;

- (CAKeyframeAnimation *)shakeAnimation:(NSRect)frame
{
    CAKeyframeAnimation *shakeAnimation = [CAKeyframeAnimation animation];
	
    CGMutablePathRef shakePath = CGPathCreateMutable();
    CGPathMoveToPoint(shakePath, NULL, NSMinX(frame), NSMinY(frame));
	int index;
	for (index = 0; index < numberOfShakes; ++index)
	{
		CGPathAddLineToPoint(shakePath, NULL, NSMinX(frame) - frame.size.width * vigourOfShake, NSMinY(frame));
		CGPathAddLineToPoint(shakePath, NULL, NSMinX(frame) + frame.size.width * vigourOfShake, NSMinY(frame));
	}
    CGPathCloseSubpath(shakePath);
    shakeAnimation.path = shakePath;
    shakeAnimation.duration = durationOfShake;
    return shakeAnimation;
}

- (id)init
{
    if (self=[super init]) {
        isConcurrent = NO;
        password = @"";
        username = @"";
        tunnelid = @"";
        aiccu = [[TKZAiccuAdapter alloc] init ];
        tunnelInfoList = [[NSMutableArray alloc] init];
        isOpenedFirstTime = YES;
    }
    
    return self;
}

- (void)windowDidBecomeKey:(NSNotification *)notification {

    if (isOpenedFirstTime) {
        NSDictionary *config = [aiccu loadAiccuConfig];
        if (config) {
            [usernameField setStringValue:[config objectForKey:@"username"]];
            [passwordField setStringValue:[config objectForKey:@"password"]];
            tunnelid = [config objectForKey:@"tunnel_id"];
            isOpenedFirstTime = NO;
            [self clickLogin:nil];
        }
    }
    [[self popover] close];
    [infoButton setState:0];
}

//- (void) windowdid

- (IBAction)clickLogin:(id)sender {    
    if ( (!isConcurrent)
        && !([password isEqualToString:[passwordField stringValue]])
        //&& !([username isEqualToString:[usernameField stringValue]])
        && !([[usernameField stringValue] isEqualToString:@""])
        && !([[passwordField stringValue] isEqualToString:@""])
        
        ) {
        
        password = [passwordField stringValue];
        username = [usernameField stringValue];
        
        isConcurrent = YES;
        
        [usernameProgress startAnimation:nil];
        [passwordProgress startAnimation:nil];
        
        [usernameCheck setHidden:YES];
        [passwordCheck setHidden:YES];
        
        [passwordField setEnabled:NO];
        [usernameField setEnabled:NO];
        
        [saveButton setEnabled:NO];
        
        [infoButton setEnabled:NO];
        [infoButton setState:0];
        
        [[self popover] close];
        
        [tunnelChoise setEnabled:NO];
 
        [self performSelector:@selector(doLogin) withObject:nil afterDelay:0.0];
    }
}

- (IBAction)clickSave:(id)sender {
    //
    NSDictionary *config = [NSDictionary dictionaryWithObjectsAndKeys:
                            username, @"username",
                            password, @"password",
                            tunnelid, @"tunnel_id",
                             nil];
    [aiccu saveAiccuConfig:config];
    [_window close];
}

- (IBAction)clickShowInfo:(id)sender {
    //
    
    if ([[self popover] isShown]) {
        [[self popover] close];
    }
    else
        [[self popover] showRelativeToRect:[sender bounds] ofView:sender preferredEdge:NSMaxYEdge];
    
}

- (void)doLogin
{
    
    NSInteger errorCode = 0;
    
    errorCode = [aiccu loginToTicServer:@"tic.sixxs.net" withUsername:username andPassword:password];
    
    
    sleep(1); ///here is the login
    
    
    
    [usernameProgress stopAnimation:nil];
    [passwordProgress stopAnimation:nil];
    
    [tunnelChoise removeAllItems];
    [tunnelInfoList removeAllObjects]; 
    
    if (!errorCode) {
        
        
        NSArray *tunnelList = [aiccu requestTunnelList];
        
        
        NSUInteger tunnelSelectIndex = 0;
        for (NSDictionary *tunnel in tunnelList)
        {
            
            [tunnelInfoList addObject:[aiccu requestTunnelInfoForTunnel:[tunnel objectForKey:@"id"]]];
            
            [tunnelChoise addItemWithTitle:[NSString stringWithFormat:@"-- %@ --", [tunnel objectForKey:@"id"]]];
            
            if ([tunnelid isEqualToString:[tunnel objectForKey:@"id"]]) {
                tunnelSelectIndex = [tunnelInfoList count] - 1;
                tunnelid = [tunnel objectForKey:@"id"];
            }
        }
        
        if ([tunnelList count]) {            
            [tunnelChoise setEnabled:YES];
            
            [tunnelChoise selectItemAtIndex:tunnelSelectIndex];
            [self choiseHasChanged:nil];
            
            [saveButton setEnabled:YES];
            [infoButton setEnabled:YES];
        }
        else {
            [tunnelChoise addItemWithTitle:@"--no tunnels--"];
            [tunnelChoise setEnabled:NO];
        }
        
        [usernameCheck setHidden:NO];
        [passwordCheck setHidden:NO];
        
        
    }
    else {
        [_window setAnimations:[NSDictionary dictionaryWithObject:[self shakeAnimation:[_window frame]] forKey:@"frameOrigin"]];
        [[_window animator] setFrameOrigin:[_window frame].origin];
        
        [usernameField setEnabled:YES]; 
        [passwordField setEnabled:YES]; 
        [passwordField becomeFirstResponder]; //does not work if becomeFirstResponder comes before setEnable
        
        [saveButton setEnabled:NO];
        [infoButton setEnabled:NO];
    }
    
    [aiccu logoutFromTicServerWithMessage:@"Bye Bye"];
    
    
    [usernameField setEnabled:YES];
    [passwordField setEnabled:YES];

    isConcurrent = NO;
}

- (IBAction)choiseHasChanged:(id)sender {
    
    NSDictionary *tunnelInfo = [tunnelInfoList objectAtIndex:[tunnelChoise indexOfSelectedItem]];
    
    tunnelid = [tunnelInfo objectForKey:@"id"];
    
    [headField setStringValue:[NSString stringWithFormat:@"Tunnel %@", [tunnelInfo objectForKey:@"id"]]];
    [infoField setStringValue:[NSString stringWithFormat:
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
    
}
- (void)awakeFromNib
{
    NSImage *checkMark = [NSImage imageNamed:@"checkmark.png"];
    
    NSImageView *chechMarkView1 = [[NSImageView alloc] initWithFrame:NSMakeRect(0, 0, usernameCheck.bounds.size.width, usernameCheck.bounds.size.height)];
    [chechMarkView1 setImageScaling:NSScaleToFit];
    [chechMarkView1 setImage:checkMark];
    [usernameCheck addSubview:chechMarkView1];
    [usernameCheck setHidden:YES];
    
    NSImageView *chechMarkView2 = [[NSImageView alloc] initWithFrame:NSMakeRect(0, 0, passwordCheck.bounds.size.width, passwordCheck.bounds.size.height)];
    [chechMarkView2 setImageScaling:NSScaleToFit];
    [chechMarkView2 setImage:checkMark];
    [passwordCheck addSubview:chechMarkView2];
    [passwordCheck setHidden:YES];
    
}



@end
