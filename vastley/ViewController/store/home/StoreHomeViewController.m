//
//  StoreHomeViewController.m
//  vastley
//
//  Created by Techsviewer on 8/15/18.
//  Copyright © 2018 brainyapps. All rights reserved.
//

#import "StoreHomeViewController.h"
#import "StoreTabViewController.h"
#import "LoginViewController.h"

@interface StoreHomeViewController ()
{
    __weak IBOutlet UIView *containerView;
    __weak IBOutlet UIView *actionView;
    __weak IBOutlet NSLayoutConstraint *constant_tailing;
    __weak IBOutlet NSLayoutConstraint *contant_leading;
    __weak IBOutlet CircleImageView *img_userThumb;
    __weak IBOutlet UILabel *lbl_userName;
    
    PFUser * me;
}
@end
static StoreHomeViewController * StoreHomeinstance;
@implementation StoreHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    StoreHomeinstance = self;
    [actionView setHidden:YES];
    
    me = [PFUser currentUser];
    [me fetchIfNeeded];
    lbl_userName.text = [NSString stringWithFormat:@"Hi, %@", me[PARSE_USER_FULLNAME]];
    [Util setImage:img_userThumb imgFile:me[PARSE_USER_AVATAR]];
    
}
+ (id) getInstance
{
    return StoreHomeinstance;
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
- (IBAction)onMenu:(id)sender {
    [UIView animateWithDuration:0.3 animations:^{
        contant_leading.constant = 250;
        constant_tailing.constant = -250;
        [self.view layoutIfNeeded];
        [actionView setHidden:NO];
    }];
}
- (IBAction)onShowRightView:(id)sender {
    [UIView animateWithDuration:0.3 animations:^{
        contant_leading.constant = 0;
        constant_tailing.constant = 0;
        [self.view layoutIfNeeded];
        [actionView setHidden:YES];
    }];
}
- (IBAction)onGotoItems:(id)sender {
    StoreTabViewController * tabCtr = [StoreTabViewController getInstance];
    [tabCtr setSelectedIndex:0];
    [self onShowRightView:nil];
}
- (IBAction)onGotoMessage:(id)sender {
    StoreTabViewController * tabCtr = [StoreTabViewController getInstance];
    [tabCtr setSelectedIndex:1];
    [self onShowRightView:nil];
}
- (IBAction)onGotoSetting:(id)sender {
    StoreTabViewController * tabCtr = [StoreTabViewController getInstance];
    [tabCtr setSelectedIndex:2];
    [self onShowRightView:nil];
}
- (IBAction)onLogOut:(id)sender {
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
