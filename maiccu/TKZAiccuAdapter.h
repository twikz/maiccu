//
//  TKZAiccuAdapter.h
//  maiccu
//
//  Created by Kristof Hannemann on 04.05.13.
//  Copyright (c) 2013 Kristof Hannemann. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const TKZAiccuDidTerminate;
extern NSString * const TKZAiccuStatus;

@interface TKZAiccuAdapter : NSObject {
@private
    struct TIC_conf	*tic;
    NSTask *_task;
    NSPipe *_pipe;
    NSTimer *_postTimer;
    NSMutableArray *_statusQueue;
    NSUInteger _statusNotificationCount;
}

@property (strong) NSDictionary *tunnelInfo;

- (NSInteger) loginToTicServer:(NSString *)server withUsername:(NSString *)username andPassword:(NSString *)password;
- (void) logoutFromTicServerWithMessage:(NSString *)message;
- (NSArray *)requestTunnelList;
- (NSDictionary *)requestTunnelInfoForTunnel:(NSString *)tunnel;

- (BOOL)saveAiccuConfig:(NSDictionary *)config toFile:(NSString *)path;
- (NSDictionary *)loadAiccuConfigFile:(NSString *)path;

- (void)startStopAiccuFrom:(NSString *)path withConfigFile:(NSString *)configPath;


//testmethods
- (NSInteger) __loginToTicServer:(NSString *)server withUsername:(NSString *)username andPassword:(NSString *)password;
- (void) __logoutFromTicServerWithMessage:(NSString *)message;
- (NSArray *)__requestTunnelList;
- (NSDictionary *)__requestTunnelInfoForTunnel:(NSString *)tunnel;

@end
