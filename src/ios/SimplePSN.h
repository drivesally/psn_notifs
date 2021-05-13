//
//  SimplePSN.h
//  Drive Sally
//
//  Created by Oleg Osin on 5/5/21.
//

#ifndef SimplePSN_h
#define SimplePSN_h

#import <Foundation/Foundation.h>
#import <Cordova/CDV.h>
#import <Cordova/CDVPlugin.h>

@interface SimplePSN : CDVPlugin
{
    NSDictionary *notificationMessage;
    NSDictionary  *params;
    BOOL    isInline;
    NSString *notificationCallbackId;
    NSString *callback;
    void (^remoteNotificationHandler)();
    void (^silentNotificationHandler)(UIBackgroundFetchResult);
    BOOL ready;
}

@property (nonatomic, copy) NSString *callbackId;
@property (nonatomic, copy) NSString *notificationCallbackId;
@property (nonatomic, copy) NSString *callback;

@property (nonatomic, strong) NSDictionary *notificationMessage;
@property (nonatomic, strong) NSDictionary  *params;
@property BOOL                          isInline;

- (void)register:(CDVInvokedUrlCommand*)command;
- (void)receiveNotifications:(CDVInvokedUrlCommand*)command;
- (void)registerUserNotificationSettings:(CDVInvokedUrlCommand*)command;

- (void)areNotificationsEnabled:(CDVInvokedUrlCommand*)command;

- (void)didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken;
- (void)didFailToRegisterForRemoteNotificationsWithError:(NSError *)error;

- (void)setNotificationMessage:(NSDictionary *)notification;
- (void)notificationReceived;

@end


#endif /* SimplePSN_h */

