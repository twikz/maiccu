//
//  TKZAiccuAdapter.m
//  maiccu
//
//  Created by Kristof Hannemann on 04.05.13.
//  Copyright (c) 2013 Kristof Hannemann. All rights reserved.
//

#import "TKZAiccuAdapter.h"
#include "tic.h"
#include "aiccu.h"

#define __cstons(__cstring__)  [NSString stringWithCString:__cstring__ encoding:NSUTF8StringEncoding]

#define nstocs(__nsstring__) (char *)[__nsstring__ cStringUsingEncoding:NSUTF8StringEncoding]

#define cstons(__cstring__)  [NSString stringWithCString:((__cstring__ != NULL) ?  __cstring__ : "") encoding:NSUTF8StringEncoding]


NSString * const TKZAiccuDidTerminate = @"AiccuDidTerminate";
NSString * const TKZAiccuStatus = @"AiccuStatus";

@implementation TKZAiccuAdapter


- (id)init
{
    if (self=[super init]) {
        self.tunnelInfo = [[NSDictionary alloc] init];
        tic = (struct TIC_conf *)malloc(sizeof(struct TIC_conf));
        memset(tic, 0, sizeof(struct TIC_conf));
        _task = nil;
                
        _postTimer = nil;

    }
    return self;
}


- (BOOL)saveAiccuConfig:(NSDictionary *)config toFile:(NSString *)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSURL *url = [[NSURL URLWithString:path] URLByDeletingLastPathComponent];
    [fileManager createDirectoryAtPath:[url path] withIntermediateDirectories:YES attributes:nil error:nil];
    
    g_aiccu = (struct AICCU_conf *)malloc(sizeof(struct AICCU_conf));
    memset(g_aiccu, 0, sizeof(struct AICCU_conf));
    
    g_aiccu->username = nstocs([config objectForKey:@"username"]);
    g_aiccu->password = nstocs([config objectForKey:@"password"]);
    g_aiccu->protocol = nstocs(@"tic");
    g_aiccu->server = nstocs(@"tic.sixxs.net");
    g_aiccu->ipv6_interface = nstocs(@"tun0");
    g_aiccu->tunnel_id = nstocs([config objectForKey:@"tunnel_id"]);
    g_aiccu->automatic = true;
    g_aiccu->setupscript = false;
    g_aiccu->requiretls = false;
    g_aiccu->verbose = false; //maybe true for debug
    g_aiccu->daemonize = true;
    g_aiccu->behindnat = [[config objectForKey:@"behindnat"] intValue]; 
    g_aiccu->pidfile = nstocs(@"#pidfile");
    g_aiccu->makebeats = true;
    g_aiccu->defaultroute = true;
    g_aiccu->noconfigure = false;
    
    
    
    if(!aiccu_SaveConfig(nstocs(path)))
    {
        free(g_aiccu);
        return NO;
    }
    
    free(g_aiccu);
    return YES;
}




- (NSDictionary *)loadAiccuConfigFile:(NSString *)path {
    //
    g_aiccu = NULL;
    aiccu_InitConfig();
    if (!aiccu_LoadConfig(nstocs(path)) ){
        NSLog(@"Unable to load aiccu config file");
        aiccu_FreeConfig();
        return nil;
    }
    
    NSDictionary *config = [NSDictionary dictionaryWithObjectsAndKeys:
                            cstons(g_aiccu->username), @"username",
                            cstons(g_aiccu->password), @"password",
                            cstons(g_aiccu->tunnel_id), @"tunnel_id",
                            [NSNumber numberWithInteger:(NSInteger)g_aiccu->behindnat], @"behindnat",
                            nil];
    
    aiccu_FreeConfig();
    
    return config;
}


- (NSDictionary *)requestTunnelInfoForTunnel:(NSString *)tunnel {
    struct TIC_Tunnel *hTunnel;
    
    hTunnel = tic_GetTunnel(tic, nstocs(tunnel));
    
    if (!hTunnel) return nil;
    
    
    return [NSDictionary dictionaryWithObjectsAndKeys:
                            cstons(hTunnel->sId), @"id",
                            cstons(hTunnel->sIPv4_Local), @"ipv4_local",
                            cstons(hTunnel->sIPv6_Local), @"ipv6_local",
                            cstons(hTunnel->sIPv4_POP), @"ipv4_pop",
                            cstons(hTunnel->sIPv6_POP), @"ipv6_pop",
                            cstons(hTunnel->sIPv6_LinkLocal), @"ipv6_linklocal",
                            cstons(hTunnel->sPassword), @"password",
                            cstons(hTunnel->sPOP_Id), @"pop_id",
                            cstons(hTunnel->sType), @"type",
                            cstons(hTunnel->sUserState), @"userstate",
                            cstons(hTunnel->sAdminState), @"adminstate",
                            [NSNumber numberWithUnsignedInt:hTunnel->nHeartbeat_Interval], @"heartbeat_intervall",
                            [NSNumber numberWithUnsignedInt:hTunnel->nIPv6_PrefixLength], @"ipv6_prefixlength",
                            [NSNumber numberWithUnsignedInt:hTunnel->nMTU], @"mtu",
                            [NSNumber numberWithUnsignedInt:hTunnel->uses_tundev], @"uses_tundev",
                            nil];
}




//this is a static test method for requestTunnelInfoForTunnel
- (NSDictionary *)__requestTunnelInfoForTunnel:(NSString *)tunnel {
    
    NSLog(@"Request tunnel info");
    
    if ([tunnel isEqualToString:@"T12345"]) {

        return [NSDictionary dictionaryWithObjectsAndKeys:
                @"T12345", @"id",
                @"heartbeat", @"ipv4_local",
                @"2a01:1234:5678:2c0::2", @"ipv6_local",
                @"1.2.3.4", @"ipv4_pop",
                @"123:1233:232:1", @"ipv6_pop",
                @"", @"ipv6_linklocal",
                @"bablablabalbal", @"password",
                @"popid01", @"pop_id",
                @"6in4-heartbeat", @"type",
                @"enabled", @"userstate",
                @"enabled", @"adminstate",
                [NSNumber numberWithUnsignedInt:60], @"heartbeat_intervall",
                [NSNumber numberWithUnsignedInt:64], @"ipv6_prefixlength",
                [NSNumber numberWithUnsignedInt:1280], @"mtu",
                [NSNumber numberWithUnsignedInt:0], @"uses_tundev",
                nil];
    
    }
    else if ([tunnel isEqualToString:@"T67890"]) {
        return [NSDictionary dictionaryWithObjectsAndKeys:
                @"T67890", @"id",
                @"ayiya", @"ipv4_local",
                @"2a01:2001:2000::1", @"ipv6_local",
                @"1.2.3.4", @"ipv4_pop",
                @"2a01::1", @"ipv6_pop",
                @"", @"ipv6_linklocal",
                @"blablabla", @"password",
                @"popo02", @"pop_id",
                @"ayiya", @"type",
                @"enabled", @"userstate",
                @"enabled", @"adminstate",
                [NSNumber numberWithUnsignedInt:60], @"heartbeat_intervall",
                [NSNumber numberWithUnsignedInt:64], @"ipv6_prefixlength",
                [NSNumber numberWithUnsignedInt:1280], @"mtu",
                [NSNumber numberWithUnsignedInt:1], @"uses_tundev",
                nil];
        
        
    }
    
    return nil;
}

- (NSArray *)requestTunnelList
{
    struct TIC_sTunnel *hsTunnel, *t;
    NSMutableArray *tunnels = [[NSMutableArray alloc] init];
    
	//if (!tic_Login(g_aiccu->tic, g_aiccu->username, g_aiccu->password, g_aiccu->server)) return 0;
    
	hsTunnel = tic_ListTunnels(tic);
    
	if (!hsTunnel) //if no tunnel is configured
	{
		
		return nil;
	}
    
    
    //catch all tunnel(-id)s from server
	for (t = hsTunnel; t; t = t->next)
	{
		//printf("%s %s %s %s\n", t->sId, t->sIPv6, t->sIPv4, t->sPOPId);
        NSDictionary *tunnelInfo =  [NSDictionary dictionaryWithObjectsAndKeys:
                                    cstons(t->sId), @"id",
                                    cstons(t->sIPv6), @"ipv6",
                                    cstons(t->sIPv4), @"ipv4",
                                    cstons(t->sPOPId), @"popid",
                                    nil];
        
        //build an array of NSDictionary
        [tunnels addObject:tunnelInfo];
	}
    
	tic_Free_sTunnel(hsTunnel);
	
    return tunnels;
}

- (NSArray *)__requestTunnelList
{
    NSLog(@"Request tunnel list");
    
        NSDictionary *tunnelInfo1 =  [NSDictionary dictionaryWithObjectsAndKeys:
                                     @"T12345", @"id",
                                     @"2a01::2", @"ipv6",
                                     @"heartbeat", @"ipv4",
                                     @"pop01", @"popid",
                                     nil];
        NSDictionary *tunnelInfo2 =  [NSDictionary dictionaryWithObjectsAndKeys:
                                     @"T67890", @"id",
                                     @"2a01::2", @"ipv6",
                                     @"ayiya", @"ipv4",
                                     @"pop02", @"popid",
                                     nil];
        
    return [NSArray arrayWithObjects:tunnelInfo1, tunnelInfo2, nil];
    //return [NSArray array];
	
}

- (NSInteger) loginToTicServer:(NSString *)server withUsername:(NSString *)username andPassword:(NSString *)password
{
    //struct TIC_conf	*tic;
    NSInteger errCode;

    errCode = tic_Login(tic, nstocs(username), nstocs(password), nstocs(server));
    
    if (errCode != true){ 
        NSLog(@"Error retrieving data from tic server!!!");
        return errCode;
    }
    return 0;
}

- (NSInteger) __loginToTicServer:(NSString *)server withUsername:(NSString *)username andPassword:(NSString *)password
{
    NSLog(@"Login to tic server");
    if ([username isEqualToString:@"foo"] && [password isEqualToString:@"bar"]) {
        return 0;
    }
    return 1;
}

- (void) logoutFromTicServerWithMessage:(NSString *)message
{
    tic_Logout(tic, nstocs(message));
    memset(tic, 0, sizeof(struct TIC_conf));
}

- (void) __logoutFromTicServerWithMessage:(NSString *)message
{
    NSLog(@"Logout from tic server");
}

- (void)startStopAiccuFrom:(NSString *)path withConfigFile:(NSString *)configPath
{
    // Is the task running?
    if (_task) {
        [_task interrupt];

    } else {
        
        _statusNotificationCount = 0;
        _statusQueue = [NSMutableArray arrayWithObjects:@"", @"", @"", @"", @"", nil];
        [_postTimer invalidate];
        
        //_status = [[NSMutableString alloc] init];
        _task = [[NSTask alloc] init];
        [_task setLaunchPath:path];
        NSArray *args = [NSArray arrayWithObjects: @"start", configPath, nil];
		[_task setArguments:args];
		
		// Create a new pipe
		_pipe = [[NSPipe alloc] init];
		[_task setStandardOutput:_pipe];
		[_task setStandardError:_pipe];
        
		NSFileHandle *fh = [_pipe fileHandleForReading];
		
		NSNotificationCenter *nc;
		nc = [NSNotificationCenter defaultCenter];
		[nc removeObserver:self];
		
		[nc addObserver:self
			   selector:@selector(dataReady:)
				   name:NSFileHandleReadCompletionNotification
				 object:fh];
		
		[nc addObserver:self
			   selector:@selector(taskTerminated:)
				   name:NSTaskDidTerminateNotification
				 object:_task];
		
		[_task launch];
				
		[fh readInBackgroundAndNotify];
	}
}


- (void)shiftFIFOArray:(NSMutableArray *)array withObject:(id)object{
    [array removeLastObject];
    [array insertObject:object atIndex:0];
}

- (void)dataReady:(NSNotification *)n
{
    NSData *d;
    d = [[n userInfo] valueForKey:NSFileHandleNotificationDataItem];
	    
	if ([d length]) {
        
         NSString *s = [[NSString alloc] initWithData:d
                                            encoding:NSUTF8StringEncoding];
        [self shiftFIFOArray:_statusQueue withObject:s];
        
        [_postTimer invalidate];        
        _statusNotificationCount++;
        
        if (_statusNotificationCount >= [_statusQueue count] - 1) {
            if(!(_statusNotificationCount % 500)) {
                [_postTimer invalidate];
                [self postAiccuStatusNotification];
            }
            else {
                _postTimer = [NSTimer scheduledTimerWithTimeInterval:4.0f target:self selector:@selector(resetStatusNotificationCount) userInfo:nil repeats:NO];
            }
        }
        else {
            
            [self postAiccuStatusNotification];
        }

        
    }
    
	// If the task is running, start reading again
    if (_task)
        [[_pipe fileHandleForReading] readInBackgroundAndNotify];
}


- (void)postAiccuStatusNotification {
    
    NSMutableString *wholeMessage = [[NSMutableString alloc] init];
    for (NSString *message in _statusQueue) {
        [wholeMessage appendString:message];
    }
    
    if (![wholeMessage isEqualToString:@""]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:TKZAiccuStatus object:wholeMessage];
    }
    
    _statusQueue = [NSMutableArray arrayWithObjects:@"", @"", @"", @"", @"", nil];

}

- (void)resetStatusNotificationCount {
    _statusNotificationCount = 0;
    [self postAiccuStatusNotification];
}

- (void)taskTerminated:(NSNotification *)note
{
    //NSLog(@"taskTerminated:");
	
    [[NSNotificationCenter defaultCenter] postNotificationName:TKZAiccuDidTerminate object:[NSNumber numberWithInt:[_task terminationStatus]]];
	_task = nil;
    //[startButton setState:0];
}

@end
