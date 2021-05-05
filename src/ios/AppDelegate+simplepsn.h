//
//  AppDelegate+simplepsn.h
//  Drive Sally
//
//  Created by Oleg Osin on 5/5/21.
//

#ifndef AppDelegate_simplepsn_h
#define AppDelegate_simplepsn_h
#import "AppDelegate.h"

@interface AppDelegate (simplepsn)
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken;
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error;
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo;
- (id) getCommandInstance:(NSString*)className;

@property (nonatomic, retain) NSDictionary    *launchNotification;

@end


#endif /* AppDelegate_simplepsn_h */
