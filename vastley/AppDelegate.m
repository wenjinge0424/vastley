//
//  AppDelegate.m
//  vastley
//
//  Created by Techsviewer on 8/14/18.
//  Copyright © 2018 brainyapps. All rights reserved.
//

#import "AppDelegate.h"
@import GoogleMaps;
@import GooglePlaces;
#import "Onboard1ViewController.h"
#import "LoginViewController.h"
#import "ChatDetailsViewController.h"
#import "UserMessageViewController.h"

@interface AppDelegate ()
{
    CLLocationManager * locationManager;
}
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
//    [GMSServices provideAPIKey:@""];
    
    locationManager = [CLLocationManager new];
    BOOL isAllowed = [CLLocationManager locationServicesEnabled];
    if(isAllowed){
        [locationManager requestWhenInUseAuthorization];
    }
    
    
    [GMSPlacesClient provideAPIKey:@"AIzaSyB18lwBHah2rYfz_nIgW8AGyMkrTFaRmDs"];
    [GIDSignIn sharedInstance].clientID = @"";
    [PFUser enableAutomaticUser];
    [Parse initializeWithConfiguration:[ParseClientConfiguration configurationWithBlock:^(id<ParseMutableClientConfiguration> configuration) {
        configuration.applicationId = @"f8cf74ad-6370-47a2-8b2d-1d513a50c9fa";
        configuration.clientKey = @"4e3b553b-afc3-4573-93df-bba18410e285";
        configuration.server = @"https://parse.jimb.tk:20014/parse";
    }]];
    [PFUser enableRevocableSessionInBackground];
    // Facebook
    [PFFacebookUtils initializeFacebookWithApplicationLaunchOptions:launchOptions];
    
    // Push Notification
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    } else {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge];
    }
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    BOOL readOnboard = [[NSUserDefaults standardUserDefaults] boolForKey:SYSTEM_KEY_READ_ONBOARD];
    UINavigationController * mainNav = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"AppMainNav"];
    if(readOnboard){
        Onboard1ViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"Onboard1ViewController"];
        [mainNav setViewControllers:@[controller] animated:NO];
    }else{
        LoginViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"LoginViewController"];
        [mainNav setViewControllers:@[controller] animated:NO];
    }
    self.window.rootViewController = mainNav;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void) application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    if ([url.absoluteString rangeOfString:@"com.googleusercontent.apps"].location != NSNotFound) {
        return [[GIDSignIn sharedInstance] handleURL:url
                                   sourceApplication:sourceApplication
                                          annotation:annotation];
    }
    
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];
}

- (BOOL)application:(UIApplication *)app
            openURL:(NSURL *)url
            options:(NSDictionary *)options {
    if ([url.absoluteString rangeOfString:@"com.googleusercontent.apps"].location != NSNotFound) {
        return [[GIDSignIn sharedInstance] handleURL:url
                                   sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]
                                          annotation:options[UIApplicationOpenURLOptionsAnnotationKey]];
    }
    
    return [[FBSDKApplicationDelegate sharedInstance] application:app
                                                          openURL:url
                                                          options:options];
}
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    application.applicationIconBadgeNumber = 0;
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [NSNotificationCenter.defaultCenter postNotificationName:NOTIFICATION_BACKGROUND object:nil];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [FBSDKAppEvents activateApp];
    [NSNotificationCenter.defaultCenter postNotificationName:NOTIFICATION_ACTIVE object:nil];
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSInteger pushType = [[userInfo objectForKey:PUSH_NOTIFICATION_TYPE] integerValue];
    application.applicationIconBadgeNumber = 0;
    
    if (application.applicationState == UIApplicationStateInactive || application.applicationState == UIApplicationStateBackground) {
        [PFAnalytics trackAppOpenedWithRemoteNotificationPayload:userInfo];
    } else { // active status
        PFInstallation *currentInstallation = [PFInstallation currentInstallation];
        currentInstallation.badge = 0;
        [currentInstallation saveInBackground];
    }
    if (pushType == PUSH_TYPE_CHAT){
        if ([ChatDetailsViewController getInstance]){
            NSString *roomId = [userInfo objectForKey:@"data"];
            if ([roomId isEqualToString:[AppStateManager sharedInstance].chatRoomId]){
                [NSNotificationCenter.defaultCenter postNotificationName:kChatReceiveNotificationUsers object:nil];
            } else {
                [PFPush handlePush:userInfo];
            }
        } else if ([UserMessageViewController getInstance]){
            [NSNotificationCenter.defaultCenter postNotificationName:kChatReceiveNotificationUsers object:nil];
        } else {
            [NSNotificationCenter.defaultCenter postNotificationName:kChatReceiveNotification object:nil];
        }
        
    } else if (pushType == PUSH_TYPE_BAN){
    }
}
- (void) checkTDBRate
{
    [self performSelector:@selector(showRateDlg) withObject:nil afterDelay:50];
}
- (void) showRateDlg
{
    NSString *msg = @"Are you sure rate app now?";
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    alert.customViewColor = MAIN_COLOR;
    alert.horizontalButtons = NO;
    
    AppDelegate * appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    [alert addButton:@"Rate Now" actionBlock:^(void) {
        NSString * url = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@", @"1423125596"];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
        appDelegate.needTDBRate = NO;
    }];
    [alert addButton:@"Maybe later" actionBlock:^(void) {
        
        appDelegate.needTDBRate = YES;
        [self performSelector:@selector(showRateDlg) withObject:nil afterDelay:10];
    }];
    [alert addButton:@"No, Thanks" actionBlock:^(void) {
        appDelegate.needTDBRate = NO;
    }];
    [alert showError:@"Rate App" subTitle:msg closeButtonTitle:nil duration:0.0f];
}
@end
