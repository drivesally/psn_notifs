//
//  AppDelegate+simplepsn.m
//  Drive Sally
//
//  Created by Oleg Osin on 5/5/21.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "AppDelegate+simplepsn.h"
#import "SimplePSN.h"


static char launchNotificationKey;

@implementation AppDelegate (simplepsn)

- (id) getCommandInstance:(NSString*)className
{
  return [self.viewController getCommandInstance:className];
}


+ (void)load
{
  Method original, swizzled;

  original = class_getInstanceMethod(self, @selector(init));
  swizzled = class_getInstanceMethod(self, @selector(swizzled_init));
  method_exchangeImplementations(original, swizzled);
}

- (AppDelegate *)swizzled_init
{
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(createNotificationChecker:)
                                               name:UIApplicationDidFinishLaunchingNotification
                                             object:nil];

  [[NSNotificationCenter defaultCenter]addObserver:self
                                          selector:@selector(onApplicationDidBecomeActive:)
                                              name:UIApplicationDidBecomeActiveNotification
                                            object:nil];

  return [self swizzled_init];
}

// This code will be called immediately after application:didFinishLaunchingWithOptions:. We need
// to process notifications in cold-start situations
- (void)createNotificationChecker:(NSNotification *)notification
{
  if (notification)
  {
    NSDictionary *launchOptions = [notification userInfo];
    if (launchOptions)
      self.launchNotification = [launchOptions objectForKey: @"UIApplicationLaunchOptionsRemoteNotificationKey"];
  }
}

- (void)onApplicationDidBecomeActive:(NSNotification *)notification
{
  NSLog(@"active");

  UIApplication *application = notification.object;

  application.applicationIconBadgeNumber = 0;

  if (self.launchNotification) {
      NSLog(@"Got notificaiton");
    SimplePSN *pushHandler = [self getCommandInstance:@"SimplePSN"];

    pushHandler.notificationMessage = self.launchNotification;
    self.launchNotification = nil;
    [pushHandler performSelectorOnMainThread:@selector(notificationReceived) withObject:pushHandler waitUntilDone:NO];
  }
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
  SimplePSN *pushHandler = [self getCommandInstance:@"SimplePSN"];
  [pushHandler didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
    NSLog(@"Did register for notification %@", deviceToken);
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
  SimplePSN *pushHandler = [self getCommandInstance:@"SimplePSN"];
  [pushHandler didFailToRegisterForRemoteNotificationsWithError:error];
    NSLog(@"Did Fail to Register for Remote Notifications");
    NSLog(@"%@, %@", error, error.localizedDescription);
}

-(void) application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    NSLog(@"GOT NOTIFICATION %@",userInfo);
}

// The accessors use an Associative Reference since you can't define a iVar in a category
// http://developer.apple.com/library/ios/#documentation/cocoa/conceptual/objectivec/Chapters/ocAssociativeReferences.html
- (NSMutableArray *)launchNotification
{
  return objc_getAssociatedObject(self, &launchNotificationKey);
}

- (void)setLaunchNotification:(NSDictionary *)aDictionary
{
  objc_setAssociatedObject(self, &launchNotificationKey, aDictionary, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)dealloc
{
  self.launchNotification = nil; // clear the association and release the object
}


@end
