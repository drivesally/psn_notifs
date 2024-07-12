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
    NSLog(@"AppDelegate.load");
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];

        SEL originalSelector = @selector(init);
        SEL swizzledSelector = @selector(swizzled_init);

        Method original = class_getInstanceMethod(class, originalSelector);
        Method swizzled = class_getInstanceMethod(class, swizzledSelector);

        BOOL didAddMethod =
        class_addMethod(class,
                        originalSelector,
                        method_getImplementation(swizzled),
                        method_getTypeEncoding(swizzled));

        if (didAddMethod) {
            class_replaceMethod(class,
                                swizzledSelector,
                                method_getImplementation(original),
                                method_getTypeEncoding(original));
        } else {
            method_exchangeImplementations(original, swizzled);
        }
    });
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
    NSLog(@"didReceiveRemoteNotification with fetchCompletionHandler");

   if (application.applicationState == UIApplicationStateActive) {
       SimplePSN *pushHandler = [self getCommandInstance:@"SimplePSN"];
       pushHandler.notificationMessage = userInfo;
       pushHandler.isInline = YES;
       [pushHandler notificationReceived];
       completionHandler(UIBackgroundFetchResultNewData);
   }
   else {
       long silent = 0;
       id aps = [userInfo objectForKey:@"aps"];
       id contentAvailable = [aps objectForKey:@"content-available"];
       if ([contentAvailable isKindOfClass:[NSString class]] && [contentAvailable isEqualToString:@"1"]) {
           silent = 1;
       } else if ([contentAvailable isKindOfClass:[NSNumber class]]) {
           silent = [contentAvailable integerValue];
       }
       
       if (silent == 1) {
           void (^safeHandler)(UIBackgroundFetchResult) = ^(UIBackgroundFetchResult result){
           dispatch_async(dispatch_get_main_queue(), ^{
               completionHandler(result);
               });
           };

           NSMutableDictionary *mutableNotification = [userInfo mutableCopy];
           NSMutableDictionary* params = [NSMutableDictionary dictionaryWithCapacity:2];
           [params setObject:safeHandler forKey:@"silentNotificationHandler"];
           SimplePSN *pushHandler = [self getCommandInstance:@"SimplePSN"];
           pushHandler.notificationMessage = mutableNotification;
           pushHandler.params= params;
           [pushHandler notificationReceived];
       } else {
           self.launchNotification = userInfo;
           completionHandler(UIBackgroundFetchResultNewData);
       }
   }
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
