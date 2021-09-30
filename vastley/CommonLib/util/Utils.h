//
//  Utils.h
//  DailyMessageTruthRevealed
//
//  Created by Techsviewer on 5/15/18.
//  Copyright © 2018 brainyapps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface Util : NSObject

+ (void) setCircleView:(UIView*) view;

+ (UIImage*) cropedImage:(UIImage*)image;

+ (NSString *) trim:(NSString *) string;
+ (NSString *) randomStringWithLength: (int) len;
+ (AppDelegate*) appDelegate;
+ (BOOL) isConnectableInternet;
+ (void)showAlertTitle:(UIViewController *)vc title:(NSString *)title message:(NSString *)message;
+ (void)showAlertTitle:(UIViewController *)vc title:(NSString *)title message:(NSString *)message finish:(void (^)(void))finish;
+ (void)showAlertTitle:(UIViewController *)vc title:(NSString *)title message:(NSString *)message info:(BOOL)info;
+ (BOOL) isPhotoAvaileble;

+ (void) setAdminNameAndPassword:(NSString*)adminName :(NSString*)password;
+ (NSString *) getAdminName;
+ (NSString *) getAdminPassword;

+ (NSString*) convertDateToString:(NSDate*)date;

+ (BOOL) stringContainsInArray:(NSString*)string :(NSArray*)stringArray;
+ (BOOL) stringContainNumber:(NSString *) string;
+ (BOOL) stringContainLetter:(NSString *) string;
+ (BOOL) isContainsUpperCase:(NSString *) password;
+ (BOOL) isContainsLowerCase:(NSString *) password;
+ (BOOL) isContainsNumber:(NSString *) password;


+ (void) setLoginUserName:(NSString*) userName password:(NSString*) password;
+ (NSString*) getLoginUserName;
+ (NSString*) getLoginUserPassword;

+ (void) setImage:(UIImageView *)imgView imgFile:(PFFile *)imgFile withDefault:(UIImage*)image;
+ (void) setImage:(UIImageView *)imgView imgFile:(PFFile *)imgFile;
+ (NSString *) downloadedURL:(NSString *)url name:(NSString *) name;
+ (void) downloadFile:(NSString *)url name:(NSString *) name completionBlock:(void (^)(NSURL *downloadurl, NSData *data, NSError *err))completionBlock;
+ (NSString *) getDocumentDirectory;
+ (NSString *)urlparseCDN:(NSString *)url;

+ (UIImage *)getUploadingImageFromImage:(UIImage *)image;

+ (void) sendPushNotification:(NSString *)email message:(NSString *)message type:(int)type;


+ (BOOL) isPhotoAvaileble;
+ (BOOL) isCameraAvailable;

@end
