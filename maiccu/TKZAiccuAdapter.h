//
//  TKZAiccuAdapter.h
//  maiccu
//
//  Created by Kristof Hannemann on 04.05.13.
//  Copyright (c) 2013 Kristof Hannemann. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TKZAiccuAdapter : NSObject {
@private
    struct TIC_conf	*tic;
}
@property (strong) NSDictionary *tunnelInfo;
@property (readonly) BOOL isRunnging;


- (NSInteger) loginToTicServer:(NSString *)server withUsername:(NSString *)username andPassword:(NSString *)password;
- (void) logoutFromTicServerWithMessage:(NSString *)message;
- (NSArray *)requestTunnelList;
- (NSDictionary *)requestTunnelInfoForTunnel:(NSString *)tunnel;

- (NSDictionary *)loadAiccuConfig;
- (BOOL)saveAiccuConfig:(NSDictionary *)config;

- (BOOL) aiccuDefaultConfigExists;
- (NSString *) aiccuDefaultConfigPath;
- (NSString *)aiccuDefaultPidFilePath;
- (BOOL) aiccuDefaultPidFileExists;
- (NSString *)aiccuDefaultPath;

- (BOOL)startAiccu;
- (BOOL)stopAiccu;




- (BOOL) runProcessAsAdministrator:(NSString*)scriptPath
                     withArguments:(NSArray *)arguments
                            output:(NSString **)output
                  errorDescription:(NSString **)errorDescription;


//testmethods
- (NSInteger) __loginToTicServer:(NSString *)server withUsername:(NSString *)username andPassword:(NSString *)password;
- (void) __logoutFromTicServerWithMessage:(NSString *)message;
- (NSArray *)__requestTunnelList;
- (NSDictionary *)__requestTunnelInfoForTunnel:(NSString *)tunnel;

@end
