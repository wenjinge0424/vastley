//
//  StoreSettingsViewController.m
//  vastley
//
//  Created by Techsviewer on 8/16/18.
//  Copyright © 2018 brainyapps. All rights reserved.
//

#import "StoreSettingsViewController.h"
#import "AboutAppViewController.h"
#import "StoreHomeViewController.h"
#import "TermsSettingViewController.h"
#import "PrivacySettingViewController.h"
#import <MessageUI/MessageUI.h>
#import "LoginViewController.h"

@interface StoreSettingsViewController ()<MFMailComposeViewControllerDelegate>
{
    PFUser * me;
    __weak IBOutlet UIView *view_Proversion;
}
@end

@implementation StoreSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    me = [PFUser currentUser];
    [me fetchIfNeeded];
    
    BOOL isProversion = [me[PARSE_USER_VIPMODE] boolValue];
    NSDate * proDate = me[PARSE_USER_PRODATE];
    NSTimeInterval remainTime = [proDate timeIntervalSinceNow] + 30*24*3600;
    if(isProversion && proDate && remainTime > 0){
        [view_Proversion setHidden:YES];
    }else{
        [view_Proversion setHidden:NO];
        me[PARSE_USER_VIPMODE] = [NSNumber numberWithBool:NO];
        [me saveInBackground];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)onEditProfile:(id)sender {
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    alert.customViewColor = MAIN_COLOR;
    alert.horizontalButtons = YES;
    [alert addButton:@"Yes" actionBlock:^(void) {
        [self onBuyProItem];
    }];
    [alert addButton:@"No" actionBlock:^(void) {

    }];
    [alert showError:@"Upgrade VIP" subTitle:@"Upgrade to VIP Premium version?" closeButtonTitle:nil duration:0.0f];
}

- (void) didUpdateToProversion
{
    me[PARSE_USER_VIPMODE] = [NSNumber numberWithBool:YES];
    me[PARSE_USER_PRODATE] = [NSDate date];
    [me saveInBackgroundWithBlock:^(BOOL success, NSError * error){
        [SVProgressHUD dismiss];
        [view_Proversion setHidden:YES];
//        [Util showAlertTitle:self title:@"" message:@"Success"];
    }];
}

- (IBAction)onRateApp:(id)sender {
    NSString *msg = @"Are you sure rate app now?";
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    alert.customViewColor = MAIN_COLOR;
    alert.horizontalButtons = NO;
    
    AppDelegate * appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    [alert addButton:@"Rate Now" actionBlock:^(void) {
        NSString * url = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@", @"1362913603"];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
        appDelegate.needTDBRate = NO;
    }];
    [alert addButton:@"Maybe later" actionBlock:^(void) {
        
        appDelegate.needTDBRate = YES;
        [appDelegate checkTDBRate];
    }];
    [alert addButton:@"No, Thanks" actionBlock:^(void) {
        appDelegate.needTDBRate = NO;
    }];
    [alert showError:@"Rate App" subTitle:msg closeButtonTitle:nil duration:0.0f];
}
- (IBAction)onSendFeedback:(id)sender {
    if([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailCont = [[MFMailComposeViewController alloc] init];
        mailCont.mailComposeDelegate = self;
        
        [mailCont setSubject:@""];
        [mailCont setToRecipients:[NSArray arrayWithObject:@"vastleyapp@gmail.com"]];
        [mailCont setMessageBody:@"" isHTML:NO];
        
        [self presentModalViewController:mailCont animated:YES];
    }
}
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    [self dismissModalViewControllerAnimated:YES];
}
- (IBAction)onAboutApp:(id)sender {
    UINavigationController * mainNav = ((StoreHomeViewController*)[StoreHomeViewController getInstance]).navigationController;
    AboutAppViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"AboutAppViewController"];
    [mainNav pushViewController:controller animated:YES];
}
- (IBAction)onTerms:(id)sender {
    UINavigationController * mainNav = ((StoreHomeViewController*)[StoreHomeViewController getInstance]).navigationController;
    TermsSettingViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"TermsSettingViewController"];
    [mainNav pushViewController:controller animated:YES];
}
- (IBAction)onPrivacy:(id)sender {
    UINavigationController * mainNav = ((StoreHomeViewController*)[StoreHomeViewController getInstance]).navigationController;
    PrivacySettingViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"PrivacySettingViewController"];
    [mainNav pushViewController:controller animated:YES];
}
- (IBAction)onLogout:(id)sender {
    [SVProgressHUD showWithStatus:@"Log out..." maskType:SVProgressHUDMaskTypeGradient];
    [PFUser logOutInBackgroundWithBlock:^(NSError *error){
        [SVProgressHUD dismiss];
        if (error){
            [Util showAlertTitle:self title:@"Log out" message:[error localizedDescription]];
        } else {
            [Util setLoginUserName:@"" password:@""];
            UINavigationController * mainNav = ((StoreHomeViewController*)[StoreHomeViewController getInstance]).navigationController;
            for(UIViewController * vc in mainNav.viewControllers){
                if ([vc isKindOfClass:[LoginViewController class]]){
                    [self.navigationController popToViewController:vc animated:YES];
                    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
                    break;
                }
            }
        }
    }];
    
}
@end
