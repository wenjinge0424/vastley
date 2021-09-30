//
//  BaseViewController.h
//  vastley
//
//  Created by Techsviewer on 8/14/18.
//  Copyright © 2018 brainyapps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Utils.h"
#import <Parse/Parse.h>
#import "SVProgressHUD.h"
#import "Config.h"
#import "SCLAlertView.h"
#import "UIImageView+AFNetworking.h"
#import "NSString+Email.h"
#import "MBProgressHUD.h"
#import "IQDropDownTextField.h"
#import "AFNetworking.h"
#import <MessageUI/MessageUI.h>
#import "CircleImageView.h"
#import "BIZPopupViewController.h"
#import "IQTextView.h"
#import "NSString+Case.h"
#import "IQTextView.h"
#import "UITextView+Placeholder.h"
#import "NSDate+NVTimeAgo.h"

@interface BaseViewController : UIViewController
- (void) onBuyProItem;
- (void) didUpdateToProversion;
@end
